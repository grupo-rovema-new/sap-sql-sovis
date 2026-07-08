CREATE OR REPLACE PROCEDURE SBO_SP_VALIDACAO_VENDA_FUTURA

(
    in object_type nvarchar(30),                 -- SBO Object Type
    in transaction_type nchar(1),                -- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
    in num_of_cols_in_key int,
    in list_of_key_cols_tab_del nvarchar(255),
    in list_of_cols_val_tab_del nvarchar(255),
    INOUT error int,
    INOUT error_message nvarchar(200)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN

DECLARE totalFrete number;
DECLARE freteAtual number;

IF :object_type IN('14') AND :transaction_type = 'A' then
	IF( EXISTS(
		SELECT
			1
		FROM
			"ORIN"
		WHERE
			"U_conciliar_automatico" = 0
			AND "DocEntry" = :list_of_cols_val_tab_del)
	) THEN
		error := '88';
    	error_message := 'Modifique o campo "Conciliar automaticamente?" para "SIM"';
END if;

SELECT
    max("sugerido"),
    max("current")
INTO
    totalFrete, freteAtual
FROM (
         SELECT
             ROUND(
                     (currentDocument."DocTotal" - COALESCE(currentDocument."TotalExpns", 0)) * contrato."U_valorFrete"
                         / NULLIF(contratoTotal."total", 0)
                 , 2, ROUND_HALF_DOWN) AS "sugerido",
             COALESCE(docFrete."LineTotal", 0) AS "current"
         FROM
             "ORIN" currentDocument
                 INNER JOIN "@AR_CONTRATO_FUTURO" contrato ON currentDocument."U_venda_futura" = contrato."DocEntry"
                 INNER JOIN (
                 SELECT "DocEntry", sum("U_quantity" * "U_precoNegociado") AS "total"
                 FROM "@AR_CF_LINHA"
                 GROUP BY "DocEntry"
             ) contratoTotal ON contratoTotal."DocEntry" = contrato."DocEntry"
                 LEFT JOIN (
                 SELECT "DocEntry", sum(COALESCE("LineTotal", 0)) AS "LineTotal"
                 FROM "RIN3"
                 WHERE "ExpnsCode" = 1
                 GROUP BY "DocEntry"
             ) docFrete ON docFrete."DocEntry" = currentDocument."DocEntry"
         WHERE
             currentDocument."DocEntry" = :list_of_cols_val_tab_del
           AND currentDocument."U_venda_futura" IS NOT NULL
     ) calculoFrete;

IF totalFrete IS NOT NULL AND abs(totalFrete - freteAtual) > 0.01 THEN
		error := 88;
    	error_message := 'O frete deve ser proporcional ao contrato. Sugestão '|| totalFrete;
END if;
END IF;

-- Devolução avulsa de venda futura -----------------------------------------------------------------
-- Bloqueia a devolução (ORIN) cujo documento base é venda futura quando a devolução é avulsa: as
-- linhas não têm vínculo com o documento base (RIN1."BaseEntry" nulo), existindo apenas a referência
-- em RIN21 -> nota fiscal base (OINV) com "U_venda_futura" preenchido. Nesse caso a devolução deve ser
-- vinculada ao documento base, não avulsa.
IF :object_type = '14' AND :transaction_type = 'A' THEN
	IF EXISTS (
		SELECT 1
		FROM "ORIN" D
			INNER JOIN "RIN1"  DL  ON D."DocEntry" = DL."DocEntry"
			INNER JOIN "RIN21" REF ON D."DocEntry" = REF."DocEntry" AND REF."RefObjType" = 13
			INNER JOIN "OINV"  NF  ON NF."DocEntry" = REF."RefDocEntr"
		WHERE
			D."DocEntry" = :list_of_cols_val_tab_del
			AND D."CANCELED" = 'N'
			AND DL."BaseEntry" IS NULL              -- linha sem vínculo com a nota base (avulsa)
			AND NF."U_venda_futura" IS NOT NULL     -- documento base é venda futura
	) THEN
		error := 7;
		error_message := 'Não é permitido devolução avulsa de contrato de venda futura';
	END IF;
END IF;


--IF :object_type IN('13') AND :transaction_type IN('A') then
--
--SELECT
--    max("sugerido"),
--    max("current")
--INTO
--    totalFrete, freteAtual
--FROM (
--         SELECT
--             ROUND(
--                     (currentDocument."DocTotal" - COALESCE(currentDocument."TotalExpns", 0)) * contrato."U_valorFrete"
--                         / NULLIF(contratoTotal."total", 0)
--                 , 2, ROUND_HALF_DOWN) AS "sugerido",
--             COALESCE(docFrete."LineTotal", 0) AS "current"
--         FROM
--             "OINV" currentDocument
--                 INNER JOIN "@AR_CONTRATO_FUTURO" contrato ON currentDocument."U_venda_futura" = contrato."DocEntry"
--                 INNER JOIN (
--                 SELECT "DocEntry", sum("U_quantity" * "U_precoNegociado") AS "total"
--                 FROM "@AR_CF_LINHA"
--                 GROUP BY "DocEntry"
--             ) contratoTotal ON contratoTotal."DocEntry" = contrato."DocEntry"
--                 LEFT JOIN (
--                 SELECT "DocEntry", sum(COALESCE("LineTotal", 0)) AS "LineTotal"
--                 FROM "INV3"
--                 WHERE "ExpnsCode" = 1
--                 GROUP BY "DocEntry"
--             ) docFrete ON docFrete."DocEntry" = currentDocument."DocEntry"
--         WHERE
--             currentDocument."DocEntry" = :list_of_cols_val_tab_del
--           AND currentDocument."U_venda_futura" IS NOT NULL
--     ) calculoFrete;
--
--IF totalFrete IS NOT NULL AND abs(totalFrete - freteAtual) > 0.01 THEN
--		error := 88;
--    	error_message := 'O frete deve ser proporcional ao contrato. Sugestão '|| totalFrete;
--END if;
--END IF;

IF :object_type IN('24','46') then
	IF( EXISTS(
		SELECT
			"ORCT".*
		FROM
			"RCT2"
			INNER JOIN "OJDT" ON "RCT2"."DocEntry" = "OJDT"."TransId"
			LEFT JOIN "ORCT" ON "RCT2"."DocNum" = "ORCT"."DocEntry"
		WHERE
			"InvType" = 30 AND "OJDT"."TransCode" in('VFET','VFEC')
			AND "ORCT"."DocEntry" = :list_of_cols_val_tab_del)) THEN
		error := '88';
    	error_message := 'Não e permitido efeturar contas a receber de uma reclassificação';
END if;
END IF;



    IF :object_type = '23' AND ( :transaction_type = 'A' OR :transaction_type = 'U') THEN
    	DECLARE v_isbn    VARCHAR(20) = '';

    	DECLARE v_contract_docentry INT;
	    DECLARE v_item_code nvarchar(50);

        DECLARE CURSOR c_cursor1 (v_isbn VARCHAR(20)) FOR
SELECT OQUT."U_venda_futura", QUT1."ItemCode"
FROM OQUT
         JOIN QUT1 ON OQUT."DocEntry" = QUT1."DocEntry"
WHERE OQUT."DocEntry" = :list_of_cols_val_tab_del;

FOR cur_row AS c_cursor1(v_isbn) DO
	      	--CALL ins_msg_proc('book title is: ' || :cur_row.title);

			-- Declaração de variáveis para armazenar o DocEntry do contrato e o ItemCode
			v_contract_docentry = cur_row."U_venda_futura";
			v_item_code = cur_row."ItemCode";


	        -- Verifica se o campo "U_venda_futura" é diferente de NULL
	        IF v_contract_docentry IS NOT NULL THEN
	            -- Verifica se existe algum valor negativo na subtração do total de contrato menos as quantidades de cotação, pedido e nota para o mesmo ItemCode
	            IF EXISTS (
	              WITH
				    CONTRATO AS
				    (
				        SELECT "DocEntry", "U_itemCode", SUM("U_quantity")AS TOTAL_CONTRATO
				        FROM "@AR_CF_LINHA"
				        WHERE "DocEntry" = :v_contract_docentry
				        GROUP BY "DocEntry", "U_itemCode"
				    ),
				    COTACAO AS
				    (
				        SELECT LINHACOTACAO."ItemCode", SUM(LINHACOTACAO."Quantity") AS TOTAL_COTACAO
				        FROM OQUT COTACAO
				        INNER JOIN QUT1 LINHACOTACAO ON COTACAO."DocEntry" = LINHACOTACAO."DocEntry"
				        INNER JOIN CONTRATO ON CONTRATO."DocEntry" = COTACAO."U_venda_futura" AND LINHACOTACAO."ItemCode" = CONTRATO."U_itemCode"
				      	WHERE "DocStatus" = 'O'
				        GROUP BY LINHACOTACAO."ItemCode"
				    ),
				    PEDIDO AS
				    (
				        SELECT LINHAPEDIDO."ItemCode", SUM(LINHAPEDIDO."Quantity") AS TOTAL_PEDIDO
				        FROM ORDR PEDIDO
				        INNER JOIN RDR1 LINHAPEDIDO ON PEDIDO."DocEntry" = LINHAPEDIDO."DocEntry"
				        INNER JOIN CONTRATO ON CONTRATO."DocEntry" = PEDIDO."U_venda_futura" AND LINHAPEDIDO."ItemCode" = CONTRATO."U_itemCode"
				        WHERE "DocStatus" = 'O'
				        GROUP BY LINHAPEDIDO."ItemCode"
				    ),
				    NOTA AS
				    (
				        SELECT LINHANOTA."ItemCode", SUM(LINHANOTA."Quantity") AS TOTAL_NOTA
				        FROM OINV NOTA
				        INNER JOIN INV1 LINHANOTA ON NOTA."DocEntry" = LINHANOTA."DocEntry"
				        INNER JOIN CONTRATO ON CONTRATO."DocEntry" = NOTA."U_venda_futura" AND LINHANOTA."ItemCode" = CONTRATO."U_itemCode"
				        WHERE "CANCELED" = 'N'
				        GROUP BY LINHANOTA."ItemCode"
				    ),
				    DEVOLUCAO AS
				    (
				        SELECT LINHANOTA."ItemCode", SUM(LINHANOTA."Quantity") AS TOTAL_NOTA
				        FROM ORIN NOTA
				        INNER JOIN RIN1 LINHANOTA ON NOTA."DocEntry" = LINHANOTA."DocEntry"
				        INNER JOIN CONTRATO ON CONTRATO."DocEntry" = NOTA."U_venda_futura" AND LINHANOTA."ItemCode" = CONTRATO."U_itemCode"
				        WHERE "CANCELED" = 'N'
				        GROUP BY LINHANOTA."ItemCode"
				    )
				    SELECT
				        CONTRATO."U_itemCode",
				        COALESCE(CONTRATO.TOTAL_CONTRATO, 0) +
				        COALESCE(DEVOLUCAO.TOTAL_NOTA, 0) -
				        COALESCE(COTACAO.TOTAL_COTACAO, 0) -
				        COALESCE(PEDIDO.TOTAL_PEDIDO, 0) -
				        COALESCE(NOTA.TOTAL_NOTA, 0) AS RESULTADO
				    FROM CONTRATO
				    LEFT JOIN COTACAO ON CONTRATO."U_itemCode" = COTACAO."ItemCode"
				    LEFT JOIN PEDIDO ON CONTRATO."U_itemCode" = PEDIDO."ItemCode"
				    LEFT JOIN NOTA ON CONTRATO."U_itemCode" = NOTA."ItemCode"
				    LEFT JOIN DEVOLUCAO ON CONTRATO."U_itemCode" = DEVOLUCAO."ItemCode"
				    WHERE
				    	CONTRATO."U_itemCode" = :v_item_code AND
						COALESCE(CONTRATO.TOTAL_CONTRATO, 0) +
				       	COALESCE(DEVOLUCAO.TOTAL_NOTA, 0) -
				  		COALESCE(COTACAO.TOTAL_COTACAO, 0) -
						COALESCE(PEDIDO.TOTAL_PEDIDO, 0) -
				      	COALESCE(NOTA.TOTAL_NOTA, 0) < 0
	            ) THEN
	                -- Se qualquer resultado for negativo para o item específico e o item está na cotação, defina o erro e a mensagem de erro
	                error := 7;
	                error_message := 'Erro: Não pode ocorrer retirada pois a quantidade é inferior ao contrato para o item ' || v_item_code;
END IF;

END IF;
END FOR;
END IF;
END;
