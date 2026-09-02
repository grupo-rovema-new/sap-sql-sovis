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
-- Folga para o residuo de arredondamento do desonerado, calculada por documento a partir da
-- quantidade e do numero de linhas. Ver "Tolerancia_Arredondamento_Desonerado".
DECLARE toleranciaResiduo number;

-- ============================================================
-- CONFIGURAÇÃO HARDCODED
-- ============================================================
-- Somente estas filiais emissoras terão a trava aplicada.
-- Troque pelos BPLId reais.
-- ============================================================


-- Pedido de venda (ORDR)
-- O total dos produtos NAO pode sair de "DocTotal" - "TotalExpns": o "DocTotal" ja vem liquido
-- do ICMS desonerado de TUDO (produtos + despesas), enquanto "TotalExpns" e a despesa BRUTA.
-- A subtracao joga o desonerado da despesa em cima dos produtos e a trava barra pedido correto.
-- Caso real (DocEntry 118927): produto 124,22 + frete 100,00, desonerado 24,22 + 19,50 ->
-- DocTotal 180,50 - TotalExpns 100,00 = 80,50 contra 100,00 negociado, faltando exatamente os
-- 19,50 do frete. Somando linha a linha e abatendo o desonerado da propria linha da 100,00.
-- O desonerado por linha vem de "RDR4", mesmo padrao das views (ver views/diretoria/Faturamento.sql).
-- O filtro por "ExpnsCode" e obrigatorio: a RDR4 guarda tambem as linhas de imposto das despesas
-- adicionais, e o frete e "LineNum" 0 na RDR3 igual ao produto e "LineNum" 0 na RDR1 - sem o filtro
-- a subconsulta soma o desonerado do frete junto e reconstroi a formula antiga por outro caminho
-- (no 118927 dava os mesmos 80,50 de "DocTotal" - "TotalExpns").
-- Imposto de linha vem com "ExpnsCode" = -1 (conferido no 118927: -1/15,25 do produto e 1/19,50
-- do frete); o <= 0 tambem cobre instalacao que grave 0 no lugar de -1.
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
        SUM(
              ROUND(COALESCE(linha."LineTotal", 0), 2)
            - ROUND(COALESCE((
                  SELECT SUM(COALESCE(NULLIF(imp."U_TX_VlDeL", 0), imp."TaxSum"))
                  FROM "RDR4" imp
                  WHERE imp."DocEntry" = linha."DocEntry"
                    AND imp."LineNum"  = linha."LineNum"
                    AND COALESCE(imp."ExpnsCode", -1) <= 0
                    AND imp."staType" IN (25, 28)
              ), 0), 2)
        ),
        2
    ),
    "Tolerancia_Arredondamento_Desonerado"(
        SUM(COALESCE(linha."Quantity", 0)),
        COUNT(1))
INTO
    valorNegociado,
    totalDocumento,
    toleranciaResiduo
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
   ) > :toleranciaResiduo
THEN
    error := 88;
    error_message :=
        'O total do documento diverge do valor negociado. Esperado '
        || TO_NVARCHAR(valorNegociado)
        || ', encontrado '
        || TO_NVARCHAR(totalDocumento)
        || ' (tolerancia '
        || TO_NVARCHAR(ROUND(:toleranciaResiduo, 2))
        || ')';
END IF;
    IF EXISTS (
        SELECT
            1
        FROM
            ORDR
        WHERE
            ORDR."GroupNum" NOT IN (-1,86,85,84,83,82,81,80,79,78,77,76,75)
            AND ORDR."BPLId" IN (17, 18)
            AND ORDR."DocEntry" = :list_of_cols_val_tab_del
            AND EXISTS (
                SELECT
                    1
                FROM
                    CLIENTEINADIMPLENTES CI
                WHERE
                    CI."CardCode" = ORDR."CardCode"
            )
    ) THEN

        error := 17;
        error_message := 'Não é permitido realizar venda para cliente com titulo vencido';

    END IF;


END IF;


-- Nota fiscal de saída (OINV)
-- O total dos produtos NAO pode sair de "DocTotal" - "TotalExpns": o "DocTotal" ja vem liquido
-- do ICMS desonerado de TUDO (produtos + despesas), enquanto "TotalExpns" e a despesa BRUTA.
-- A subtracao joga o desonerado da despesa em cima dos produtos e a trava barra pedido correto.
-- Caso real (DocEntry 118927): produto 124,22 + frete 100,00, desonerado 24,22 + 19,50 ->
-- DocTotal 180,50 - TotalExpns 100,00 = 80,50 contra 100,00 negociado, faltando exatamente os
-- 19,50 do frete. Somando linha a linha e abatendo o desonerado da propria linha da 100,00.
-- O desonerado por linha vem de "INV4", mesmo padrao das views (ver views/diretoria/Faturamento.sql).
-- O filtro por "ExpnsCode" e obrigatorio: a INV4 guarda tambem as linhas de imposto das despesas
-- adicionais, e o frete e "LineNum" 0 na INV3 igual ao produto e "LineNum" 0 na INV1 - sem o filtro
-- a subconsulta soma o desonerado do frete junto e reconstroi a formula antiga por outro caminho
-- (no 118927 dava os mesmos 80,50 de "DocTotal" - "TotalExpns").
-- Imposto de linha vem com "ExpnsCode" = -1 (conferido no 118927: -1/15,25 do produto e 1/19,50
-- do frete); o <= 0 tambem cobre instalacao que grave 0 no lugar de -1.
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
            SUM(
                  ROUND(COALESCE(linha."LineTotal", 0), 2)
                - ROUND(COALESCE((
                      SELECT SUM(COALESCE(NULLIF(imp."U_TX_VlDeL", 0), imp."TaxSum"))
                      FROM "INV4" imp
                      WHERE imp."DocEntry" = linha."DocEntry"
                        AND imp."LineNum"  = linha."LineNum"
                        AND COALESCE(imp."ExpnsCode", -1) <= 0
                        AND imp."staType" IN (25, 28)
                  ), 0), 2)
            ),
            2
        ),
        "Tolerancia_Arredondamento_Desonerado"(
            SUM(COALESCE(linha."Quantity", 0)),
            COUNT(1))
    INTO
        valorNegociado,
        totalDocumento,
        toleranciaResiduo
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
            FROM "INV1" linha_negociada
            WHERE
                linha_negociada."DocEntry" = cab."DocEntry"
                AND COALESCE(linha_negociada."U_preco_negociado", 0) > 0
        );

    IF valorNegociado IS NOT NULL
       AND ABS(
           ROUND(valorNegociado, 2)
           - ROUND(totalDocumento, 2)
       ) > :toleranciaResiduo
    THEN
        error := 88;
        error_message :=
              'O total do documento diverge do valor negociado. Esperado '
            || TO_NVARCHAR(valorNegociado)
            || ', encontrado '
            || TO_NVARCHAR(totalDocumento)
            || ' (tolerancia '
            || TO_NVARCHAR(ROUND(:toleranciaResiduo, 2))
            || ')';
    END IF;

END IF;

END;
