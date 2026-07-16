CREATE OR replace  PROCEDURE SBO_SP_VALIDACAO_VENDA

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
    ROUND(
        SUM(
            CASE
                WHEN COALESCE(linha."U_preco_negociado", 0) > 0
                THEN ROUND(
                    linha."U_preco_negociado" * linha."Quantity",
                    2
                )
                ELSE ROUND(
                    COALESCE(linha."LineTotal", 0),
                    2
                )
            END
        ),
        2
    ),
    ROUND(
        MAX(
            COALESCE(cab."DocTotal", 0)
            - COALESCE(cab."TotalExpns", 0)
        ),
        2
    )
INTO
    valorNegociado,
    totalDocumento
FROM
    "ORDR" cab
    INNER JOIN "RDR1" linha
        ON linha."DocEntry" = cab."DocEntry"
    INNER JOIN "OUSG" usg
        ON usg."ID" = linha."Usage"
WHERE
    cab."DocEntry" = :list_of_cols_val_tab_del

    -- Trava somente para essas filiais
    AND cab."BPLId" IN (2, 4, 11, 17, 18)

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
        FROM "RDR1" linha_negociada
        WHERE
            linha_negociada."DocEntry" = cab."DocEntry"
            AND COALESCE(linha_negociada."U_preco_negociado", 0) > 0
    );

IF valorNegociado IS NOT NULL
   AND ABS(
       ROUND(valorNegociado, 2)
       - ROUND(totalDocumento, 2)
   ) > 0.01
THEN
    error := 88;
    error_message :=
        'O total do documento diverge do valor negociado. Esperado '
        || TO_NVARCHAR(valorNegociado)
        || ', encontrado '
        || TO_NVARCHAR(totalDocumento);
END IF;

END IF;


-- Nota fiscal de saída (OINV)
IF :object_type IN ('13') AND :transaction_type IN ('A','U') THEN

    SELECT
        ROUND(
            SUM(
                CASE
                    WHEN COALESCE(linha."U_preco_negociado", 0) > 0
                    THEN ROUND(
                        linha."U_preco_negociado" * linha."Quantity",
                        2
                    )
                    ELSE ROUND(
                        COALESCE(linha."LineTotal", 0),
                        2
                    )
                END
            ),
            2
        ),
        ROUND(
            MAX(
                  COALESCE(cab."DocTotal", 0)
                - COALESCE(cab."TotalExpns", 0)
                - COALESCE(cab."TaxOnExp", 0)
            ),
            2
        )
    INTO
        valorNegociado,
        totalDocumento
    FROM
        "OINV" cab
        INNER JOIN "INV1" linha
            ON linha."DocEntry" = cab."DocEntry"
        INNER JOIN "OUSG" usg
            ON usg."ID" = linha."Usage"
    WHERE
        cab."DocEntry" = :list_of_cols_val_tab_del

        -- Trava somente para essas filiais emissoras
        AND cab."BPLId" IN (2, 4, 11, 17, 18)

        AND COALESCE(usg."FreeChrgBP", 'N') = 'N'

        -- Não aplica quando o cliente da nota é uma filial do próprio sistema
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
            FROM "INV1" linha_negociada
            WHERE
                linha_negociada."DocEntry" = cab."DocEntry"
                AND COALESCE(linha_negociada."U_preco_negociado", 0) > 0
        );

    IF valorNegociado IS NOT NULL
       AND ABS(
           ROUND(valorNegociado, 2)
           - ROUND(totalDocumento, 2)
       ) > 0.01
    THEN
        error := 88;
        error_message :=
              'O total do documento diverge do valor negociado. Esperado '
            || TO_NVARCHAR(valorNegociado)
            || ', encontrado '
            || TO_NVARCHAR(totalDocumento);
    END IF;

END IF;

END;