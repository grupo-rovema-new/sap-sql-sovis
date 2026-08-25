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
	DECLARE contratoVfDev int = NULL;
	DECLARE bypassFreteDev int = 0;

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

-- Frete da devolução de venda futura ---------------------------------------------------------
-- A devolução estorna exatamente a fatia de frete que a nota devolvida cobrou, não a proporção
-- teórica do contrato:
--
--     frete = SOMA por nota base de ( frete da nota * base devolvida da nota / base da nota )
--
-- Se a nota devolvida saiu com frete a maior ou a menor, é esse mesmo valor que volta - do
-- contrário a devolução seria barrada por divergir de uma proporção que a nota nunca usou. O
-- saldo devolvido volta para o contrato (ver bloco do object_type 13, que desconta as ORIN do
-- acumulado) e as próximas retiradas reabsorvem a diferença.
-- Depende de RIN1."BaseEntry" preenchido, garantido pela validação de devolução avulsa abaixo.
--
-- Bypass: documento cujo "U_Rov_Funcionario" contém "windson" não é barrado pela conferência de
-- frete (ver bloco do object_type 13). Escape manual para regularizar documento que precisa sair
-- com frete fora da regra - o cálculo continua rodando, só o bloqueio é dispensado.
	SELECT
		max("U_venda_futura"),
		max(CASE WHEN UPPER(IFNULL("U_Rov_Funcionario", '')) LIKE '%WINDSON%' THEN 1 ELSE 0 END)
	INTO
		contratoVfDev, bypassFreteDev
	FROM "ORIN"
	WHERE "DocEntry" = :list_of_cols_val_tab_del AND "U_venda_futura" IS NOT NULL;

	IF :contratoVfDev IS NOT NULL THEN
		SELECT
			COALESCE(sum(ROUND(notaBase."frete" * devolvido."base" / NULLIF(notaBase."base", 0), 2, ROUND_HALF_DOWN)), 0)
		INTO
			totalFrete
		FROM (
				SELECT
					linha."BaseEntry" AS "nota",
					sum(ROUND(linha."Quantity" * COALESCE(linha."U_preco_negociado", linha."PriceBefDi", 0), 2)) AS "base"
				FROM "RIN1" linha
				WHERE
					linha."DocEntry" = :list_of_cols_val_tab_del
					AND linha."BaseType" = 13
					AND linha."BaseEntry" IS NOT NULL
				GROUP BY linha."BaseEntry"
			) devolvido
			INNER JOIN (
				SELECT
					nota."DocEntry" AS "nota",
					(SELECT sum(ROUND(l."Quantity" * COALESCE(l."U_preco_negociado", l."PriceBefDi", 0), 2))
					 FROM "INV1" l WHERE l."DocEntry" = nota."DocEntry") AS "base",
					(SELECT COALESCE(sum(COALESCE(e."LineTotal", 0)), 0)
					 FROM "INV3" e WHERE e."DocEntry" = nota."DocEntry" AND e."ExpnsCode" = 1) AS "frete"
				FROM "OINV" nota
				WHERE nota."DocEntry" IN (
					SELECT l."BaseEntry" FROM "RIN1" l
					WHERE l."DocEntry" = :list_of_cols_val_tab_del
					  AND l."BaseType" = 13
					  AND l."BaseEntry" IS NOT NULL
				)
			) notaBase ON notaBase."nota" = devolvido."nota";

		SELECT
			COALESCE(sum(COALESCE("LineTotal", 0)), 0)
		INTO
			freteAtual
		FROM "RIN3"
		WHERE "DocEntry" = :list_of_cols_val_tab_del AND "ExpnsCode" = 1;

		IF IFNULL(:bypassFreteDev, 0) = 0 AND abs(:totalFrete - :freteAtual) > 0.01 THEN
			error := 88;
			error_message := 'O frete da devolução deve estornar o frete da nota devolvida. Sugestão '|| :totalFrete;
		END if;
	END IF;
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


-- Frete da nota de entrega de venda futura ----------------------------------------------------
-- O frete é rateado sobre o SALDO do contrato, não sobre o contrato inteiro:
--
--     frete = (valorFrete do contrato - frete já faturado) * base desta nota
--             / (base do contrato - base já faturada)
--
-- Assim a nota absorve o desvio das anteriores: se alguma saiu com frete a maior ou a menor, o
-- residual encolhe/aumenta e as seguintes se ajustam sozinhas. Na última entrega a base da nota
-- iguala a base residual, então o frete dela é exatamente o residual e o somatório do contrato
-- sempre fecha no valorFrete contratado. Mesma fórmula de PedidoRetirada.freteResidual no
-- sap-rovema - as duas precisam andar juntas, senão toda nota nova é barrada aqui.
--
-- Residual não positivo (contrato já cobrou todo o frete, ou cobrou a maior) sugere zero: a nota
-- sai sem despesa de frete e passa, não se lança despesa adicional negativa.
IF :object_type IN('13') AND :transaction_type IN('A') then
	DECLARE contratoVf        int    = NULL;
	DECLARE bypassFrete       int    = 0;
	DECLARE freteContrato     number = 0;
	DECLARE baseContrato      number = 0;
	DECLARE freteAcumulado    number = 0;
	DECLARE baseAcumulada     number = 0;
	DECLARE baseAtual         number = 0;
	DECLARE freteResidual     number = 0;
	DECLARE baseResidual      number = 0;

	-- só nota de entrega real; a nota de apropriação de adiantamento (INV9) nunca seta
	-- U_entrega_vf, então fica de fora.
	-- bypassFrete: "U_Rov_Funcionario" contendo "windson" dispensa o bloqueio (o valor sugerido
	-- continua sendo calculado, só não vira erro).
	SELECT
		max("U_venda_futura"),
		max(CASE WHEN UPPER(IFNULL("U_Rov_Funcionario", '')) LIKE '%WINDSON%' THEN 1 ELSE 0 END)
	INTO
		contratoVf, bypassFrete
	FROM "OINV"
	WHERE
		"DocEntry" = :list_of_cols_val_tab_del
		AND "U_venda_futura" IS NOT NULL
		AND IFNULL("U_entrega_vf", '0') = '1';

	IF :contratoVf IS NOT NULL THEN
		SELECT max(contrato."U_valorFrete"), max(contratoTotal."total")
		INTO freteContrato, baseContrato
		FROM "@AR_CONTRATO_FUTURO" contrato
			INNER JOIN (
				SELECT "DocEntry", sum("U_quantity" * "U_precoNegociado") AS "total"
				FROM "@AR_CF_LINHA"
				GROUP BY "DocEntry"
			) contratoTotal ON contratoTotal."DocEntry" = contrato."DocEntry"
		WHERE contrato."DocEntry" = :contratoVf;

		-- tudo que o contrato faturou ANTES desta nota; devolução entra negativa, devolvendo
		-- saldo de base e de frete para o contrato
		SELECT COALESCE(sum("base"), 0), COALESCE(sum("frete"), 0)
		INTO baseAcumulada, freteAcumulado
		FROM (
			SELECT
				nota."DocTotal" - COALESCE(nota."TotalExpns", 0) AS "base",
				COALESCE(despesa."LineTotal", 0)                 AS "frete"
			FROM "OINV" nota
				LEFT JOIN (
					SELECT "DocEntry", sum(COALESCE("LineTotal", 0)) AS "LineTotal"
					FROM "INV3" WHERE "ExpnsCode" = 1 GROUP BY "DocEntry"
				) despesa ON despesa."DocEntry" = nota."DocEntry"
			WHERE
				nota."U_venda_futura" = :contratoVf
				AND nota."CANCELED" = 'N'
				AND IFNULL(nota."U_entrega_vf", '0') = '1'
				AND nota."DocEntry" <> :list_of_cols_val_tab_del   -- a própria nota fica de fora
			UNION ALL
			SELECT
				-(devolucao."DocTotal" - COALESCE(devolucao."TotalExpns", 0)),
				-COALESCE(despesa."LineTotal", 0)
			FROM "ORIN" devolucao
				LEFT JOIN (
					SELECT "DocEntry", sum(COALESCE("LineTotal", 0)) AS "LineTotal"
					FROM "RIN3" WHERE "ExpnsCode" = 1 GROUP BY "DocEntry"
				) despesa ON despesa."DocEntry" = devolucao."DocEntry"
			WHERE
				devolucao."U_venda_futura" = :contratoVf
				AND devolucao."CANCELED" = 'N'
		) faturado;

		SELECT
			COALESCE(max(nota."DocTotal" - COALESCE(nota."TotalExpns", 0)), 0),
			COALESCE(max(despesa."LineTotal"), 0)
		INTO baseAtual, freteAtual
		FROM "OINV" nota
			LEFT JOIN (
				SELECT "DocEntry", sum(COALESCE("LineTotal", 0)) AS "LineTotal"
				FROM "INV3" WHERE "ExpnsCode" = 1 GROUP BY "DocEntry"
			) despesa ON despesa."DocEntry" = nota."DocEntry"
		WHERE nota."DocEntry" = :list_of_cols_val_tab_del;

		freteResidual := :freteContrato - :freteAcumulado;
		baseResidual  := :baseContrato  - :baseAcumulada;

		-- residual não positivo: o contrato já cobrou todo o frete (ou cobrou a maior). A nota
		-- sai sem frete e passa - não se lança despesa adicional negativa.
		IF :freteResidual <= 0 OR :baseResidual <= 0 THEN
			totalFrete := 0;
		ELSE
			SELECT ROUND(:freteResidual * :baseAtual / :baseResidual, 2, ROUND_HALF_DOWN)
			INTO totalFrete
			FROM "DUMMY";
		END IF;

		IF IFNULL(:bypassFrete, 0) = 0 AND abs(:totalFrete - :freteAtual) > 0.01 THEN
			error := 88;
			error_message := 'O frete deve ser proporcional ao saldo do contrato. Sugestão '|| :totalFrete;
		END if;
	END IF;
END IF;

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

-- Adiantamento de venda futura fora do contrato -----------------------------------------------
-- Um adiantamento (ODPI) marcado com "U_venda_futura" é dinheiro que o cliente pagou por aquele
-- contrato. Só pode ser apropriado (INV9) por uma nota do MESMO contrato. Sem isso o passivo do
-- contrato é baixado sem a saída da mercadoria e a conciliação automática (VFET -> VFEC) nunca
-- fecha, deixando o contrato preso.

IF :object_type = '13' AND :transaction_type IN ('A') THEN
	DECLARE contratoAdt nvarchar(50) = '';

	SELECT
		MAX(IFNULL(TRIM(ADT."U_venda_futura"), ''))
	INTO
		contratoAdt
	FROM
		"OINV" NOTA
		INNER JOIN "INV9" APROP ON APROP."DocEntry" = NOTA."DocEntry"
		INNER JOIN "ODPI" ADT   ON ADT."DocEntry"   = APROP."BaseAbs"
	WHERE
		NOTA."DocEntry" = :list_of_cols_val_tab_del
		AND NOTA."CANCELED" = 'N'
		AND IFNULL(TRIM(ADT."U_venda_futura"), '') <> ''                            -- adiantamento é de venda futura
		AND IFNULL(TRIM(NOTA."U_venda_futura"), '')
			<> IFNULL(TRIM(ADT."U_venda_futura"), '');                              -- nota é de outro contrato (ou de nenhum)

	IF IFNULL(contratoAdt, '') <> '' THEN
		error := 7;
		error_message := 'Adiantamento do contrato de venda futura ' || contratoAdt ||
			' só pode ser utilizado em nota do próprio contrato.';
	END IF;
END IF;

-- Cobrança em entrega de venda futura ---------------------------------------------------------
-- A cobrança da venda futura já foi emitida nos boletos dos adiantamentos do contrato. A nota de
-- entrega da retirada não pode sair com forma de pagamento ligada a carteira do BankPlus, senão
-- é emitido um segundo boleto sobre a mesma mercadoria.
IF :object_type = '13' AND :transaction_type IN ('A','U') THEN
	IF EXISTS (
		SELECT 1
		FROM "OINV" NOTA
		WHERE
			NOTA."DocEntry" = :list_of_cols_val_tab_del
			AND NOTA."CANCELED" = 'N'
			AND NOTA."DocStatus" = 'O'
			AND IFNULL(TRIM(NOTA."U_venda_futura"), '') <> ''
			AND IFNULL(NOTA."U_entrega_vf", '0') = '1'                              -- é a nota de entrega/retirada
			AND EXISTS (
				SELECT 1
				FROM "IV_IB_ContractBank" CB
				WHERE CB."PayMethCode" = NOTA."PeyMethod"                           -- forma de pagamento gera boleto
			)
	) THEN
		error := 7;
		error_message := 'Entrega de venda futura não pode ter forma de pagamento de cobrança. ' ||
			'Retire a forma de pagamento de boleto — a cobrança já foi feita nos boletos do contrato.';
	END IF;
END IF;
END;
