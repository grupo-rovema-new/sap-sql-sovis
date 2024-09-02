CREATE PROCEDURE SBO_SP_VALIDACAO_VENDA_FUTURA
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
    IF :object_type = '23' AND ( :transaction_type = 'A' OR :transaction_type = 'U') THEN

        -- Declaração de variáveis para armazenar o DocEntry do contrato e o ItemCode
        DECLARE v_contract_docentry INT;
        DECLARE v_item_code nvarchar(50);

        -- Seleciona o DocEntry do contrato e o ItemCode com base na cotação recebida e nos itens da cotação
        SELECT OQUT."U_venda_futura", QUT1."ItemCode"
        INTO v_contract_docentry, v_item_code
        FROM OQUT
        JOIN QUT1 ON OQUT."DocEntry" = QUT1."DocEntry"
        WHERE OQUT."DocEntry" = :list_of_cols_val_tab_del;

        -- Verifica se o campo "U_venda_futura" é diferente de NULL
        IF v_contract_docentry IS NOT NULL THEN

            -- Verifica se existe algum valor negativo na subtração do total de contrato menos as quantidades de cotação, pedido e nota para o mesmo ItemCode
            IF EXISTS (
                WITH 
                CONTRATO AS 
                (
                    SELECT "DocEntry", "U_itemCode", "U_quantity" AS TOTAL_CONTRATO 
                    FROM "@AR_CF_LINHA" 
                    WHERE "DocEntry" = v_contract_docentry
                ),
                COTACAO AS
                (
                    SELECT LINHACOTACAO."ItemCode", SUM(LINHACOTACAO."Quantity") AS TOTAL_COTACAO 
                    FROM OQUT COTACAO
                    INNER JOIN QUT1 LINHACOTACAO ON COTACAO."DocEntry" = LINHACOTACAO."DocEntry"
                    INNER JOIN CONTRATO ON CONTRATO."DocEntry" = COTACAO."U_venda_futura" AND LINHACOTACAO."ItemCode" = CONTRATO."U_itemCode"
                    GROUP BY LINHACOTACAO."ItemCode"
                ),
                PEDIDO AS 
                (
                    SELECT LINHAPEDIDO."ItemCode", SUM(LINHAPEDIDO."Quantity") AS TOTAL_PEDIDO 
                    FROM ORDR PEDIDO
                    INNER JOIN RDR1 LINHAPEDIDO ON PEDIDO."DocEntry" = LINHAPEDIDO."DocEntry"
                    INNER JOIN CONTRATO ON CONTRATO."DocEntry" = PEDIDO."U_venda_futura" AND LINHAPEDIDO."ItemCode" = CONTRATO."U_itemCode"
                    GROUP BY LINHAPEDIDO."ItemCode"
                ),
                NOTA AS
                (
                    SELECT LINHANOTA."ItemCode", SUM(LINHANOTA."Quantity") AS TOTAL_NOTA 
                    FROM OINV NOTA
                    INNER JOIN INV1 LINHANOTA ON NOTA."DocEntry" = LINHANOTA."DocEntry"
                    INNER JOIN CONTRATO ON CONTRATO."DocEntry" = NOTA."U_venda_futura" AND LINHANOTA."ItemCode" = CONTRATO."U_itemCode"
                    GROUP BY LINHANOTA."ItemCode"
                )
                SELECT 
                    CONTRATO."U_itemCode", 
                    COALESCE(CONTRATO.TOTAL_CONTRATO, 0) - 
                    COALESCE(COTACAO.TOTAL_COTACAO, 0) - 
                    COALESCE(PEDIDO.TOTAL_PEDIDO, 0) - 
                    COALESCE(NOTA.TOTAL_NOTA, 0) AS RESULTADO 
                FROM CONTRATO
                LEFT JOIN COTACAO ON CONTRATO."U_itemCode" = COTACAO."ItemCode"
                LEFT JOIN PEDIDO ON CONTRATO."U_itemCode" = PEDIDO."ItemCode"
                LEFT JOIN NOTA ON CONTRATO."U_itemCode" = NOTA."ItemCode"
                WHERE CONTRATO."U_itemCode" = v_item_code -- Verifica apenas o item em questão
                  AND COALESCE(CONTRATO.TOTAL_CONTRATO, 0) - 
                      COALESCE(COTACAO.TOTAL_COTACAO, 0) - 
                      COALESCE(PEDIDO.TOTAL_PEDIDO, 0) - 
                      COALESCE(NOTA.TOTAL_NOTA, 0) < 0
            ) THEN 
                -- Se qualquer resultado for negativo para o item específico e o item está na cotação, defina o erro e a mensagem de erro
                error := 1;
                error_message := 'Erro: Não pode ocorrer retirada pois a quantidade é inferior ao contrato para o item ' || v_item_code;
            END IF;

        END IF;

    END IF;
END;
