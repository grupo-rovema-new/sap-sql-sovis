CREATE OR REPLACE PROCEDURE SBO_SP_VALIDACAO_VENDA

(
    in object_type nvarchar(30),
    in transaction_type nchar(1),
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

DECLARE valorNegociado number;
DECLARE totalDocumento number;

-- ============================================================
-- CONFIGURAÇÃO HARDCODED
-- ============================================================
-- Somente estas filiais emissoras terão a trava aplicada.
-- Troque pelos BPLId reais.
-- ============================================================


-- Pedido de venda (ORDR)
IF :object_type IN ('17') AND :transaction_type IN ('A','U') THEN

    SELECT
        sum(COALESCE(NULLIF(linha."U_preco_negociado", 0) * linha."Quantity", linha."LineTotal")),
        max(COALESCE(cab."DocTotal", 0) - COALESCE(cab."TotalExpns", 0))
    INTO
        valorNegociado,
        totalDocumento
    FROM
        "ORDR" cab
        INNER JOIN "RDR1" linha ON linha."DocEntry" = cab."DocEntry"
        INNER JOIN "OUSG" usg   ON usg."ID" = linha."Usage"
    WHERE
        cab."DocEntry" = :list_of_cols_val_tab_del

        -- Trava somente para essas filiais
        AND cab."BPLId" IN (2,4,11,17,18)
        AND COALESCE(usg."FreeChrgBP", 'N') = 'N'   
        
        AND NOT EXISTS (
            SELECT 1
            FROM "OBPL" filial_cliente
            WHERE
                filial_cliente."DflCust" = cab."CardCode"
                AND COALESCE(filial_cliente."Disabled", 'N') = 'N'
        )

        AND COALESCE(cab."U_pedido_update", '0') <> '1'

        AND EXISTS (
            SELECT 1
            FROM "RDR1"
            WHERE
                "DocEntry" = cab."DocEntry"
                AND "U_preco_negociado" > 0
        );

    IF valorNegociado IS NOT NULL AND abs(valorNegociado - totalDocumento) > 0.01 THEN
        error := 88;
        error_message := 'O total do documento diverge do valor negociado. Esperado ' || valorNegociado;
    END IF;

END IF;


-- Nota fiscal de saída (OINV)
IF :object_type IN ('13') AND :transaction_type IN ('A','U') THEN

    SELECT
        sum(COALESCE(NULLIF(linha."U_preco_negociado", 0) * linha."Quantity", linha."LineTotal")),
        max(COALESCE(cab."DocTotal", 0) - COALESCE(cab."TotalExpns", 0))
    INTO
        valorNegociado,
        totalDocumento
    FROM
        "OINV" cab
        INNER JOIN "INV1" linha ON linha."DocEntry" = cab."DocEntry"
        INNER JOIN "OUSG" usg   ON usg."ID" = linha."Usage"
    WHERE
        cab."DocEntry" = :list_of_cols_val_tab_del

        -- Trava somente para essas filiais emissoras
        AND cab."BPLId" IN (2,4,11,17,18)
        AND COALESCE(usg."FreeChrgBP", 'N') = 'N' 

        -- Não aplica a trava quando o cliente da nota é uma filial do próprio sistema.
        -- A lista vem dinamicamente da OBPL.DflCust.
        AND NOT EXISTS (
            SELECT 1
            FROM "OBPL" filial_cliente
            WHERE
                filial_cliente."DflCust" = cab."CardCode"
                AND COALESCE(filial_cliente."Disabled", 'N') = 'N'
        )

        -- Bypass temporário
        AND COALESCE(cab."U_pedido_update", '0') <> '1'

        AND EXISTS (
            SELECT 1
            FROM "INV1"
            WHERE
                "DocEntry" = cab."DocEntry"
                AND "U_preco_negociado" > 0
        );

    IF valorNegociado IS NOT NULL AND abs(valorNegociado - totalDocumento) > 0.01 THEN
        error := 88;
        error_message := 'O total do documento diverge do valor negociado. Esperado ' || valorNegociado;
    END IF;

END IF;

END;