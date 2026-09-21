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

-- Compara o valor combinado com o total FINAL do documento, incluindo frete.
-- Esperado = produtos negociados + frete negociado + demais despesas lancadas.
-- Frete (ExpnsCode 1): U_frete_negociado positivo, senao LineTotal, como no servico.
-- TotalExpns ja inclui frete: substituimos sua parcela bruta pelo valor negociado.
-- As despesas sao agregadas antes do join para nao multiplica-las pelo numero de itens.
-- Encontrado = DocTotal. Nao subtrair novamente impostos de RDR4/INV4, inclusive tipo 10.
-- Cotacao 176603: produtos 27330,71 + frete 3960,00 = 31290,71;
-- DocTotal 31290,73, diferenca 0,02 dentro da tolerancia 0,132.
-- Mantidos os filtros de filial, utilizacao, cliente-filial e calculo pendente.

-- Pedido de venda
IF :object_type = '17' AND :transaction_type IN ('A','U') THEN

    SELECT
        ROUND(
            SUM(
                CASE
                    WHEN COALESCE(linha."U_preco_negociado", 0) > 0
                        THEN ROUND(linha."U_preco_negociado" * linha."Quantity", 2)
                    ELSE ROUND(COALESCE(linha."LineTotal", 0), 2)
                END
            )
            + MAX(
                COALESCE(cab."TotalExpns", 0)
                - COALESCE(frete."FreteLancado", 0)
                + COALESCE(frete."FreteEsperado", 0)
            ),
            2
        ),
        ROUND(MAX(cab."DocTotal"), 2),
        "Tolerancia_Arredondamento_Desonerado"(
            SUM(COALESCE(linha."Quantity", 0)), COUNT(1))
    INTO
        valorNegociado,
        totalDocumento,
        toleranciaResiduo
    FROM "ORDR" cab
    INNER JOIN "RDR1" linha ON linha."DocEntry" = cab."DocEntry"
    INNER JOIN "OUSG" usg ON usg."ID" = linha."Usage"
    LEFT JOIN (
        SELECT d."DocEntry",
            SUM(COALESCE(d."LineTotal", 0)) AS "FreteLancado",
            SUM(
                CASE
                    WHEN COALESCE(d."U_frete_negociado", 0) > 0 THEN d."U_frete_negociado"
                    ELSE COALESCE(d."LineTotal", 0)
                END
            ) AS "FreteEsperado"
        FROM "RDR3" d
        WHERE d."ExpnsCode" = 1
          AND d."DocEntry" = :list_of_cols_val_tab_del
        GROUP BY d."DocEntry"
    ) frete ON frete."DocEntry" = cab."DocEntry"
    WHERE cab."DocEntry" = :list_of_cols_val_tab_del
      AND cab."BPLId" IN (2, 4, 11, 17, 18)
      AND COALESCE(usg."FreeChrgBP", 'N') = 'N'
      AND NOT EXISTS (
          SELECT 1 FROM "OBPL" filial_cliente
          WHERE filial_cliente."DflCust" = cab."CardCode"
            AND COALESCE(filial_cliente."Disabled", 'N') = 'N'
      )
      AND COALESCE(cab."U_pedido_update", '0') <> '1'
      AND EXISTS (
          SELECT 1 FROM "RDR1" linha_negociada
          WHERE linha_negociada."DocEntry" = cab."DocEntry"
            AND COALESCE(linha_negociada."U_preco_negociado", 0) > 0
      );

    IF valorNegociado IS NOT NULL
       AND ABS(ROUND(valorNegociado, 2) - ROUND(totalDocumento, 2)) > :toleranciaResiduo
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

-- Nota fiscal de saida
IF :object_type = '13' AND :transaction_type IN ('A','U') THEN

    SELECT
        ROUND(
            SUM(
                CASE
                    WHEN COALESCE(linha."U_preco_negociado", 0) > 0
                        THEN ROUND(linha."U_preco_negociado" * linha."Quantity", 2)
                    ELSE ROUND(COALESCE(linha."LineTotal", 0), 2)
                END
            )
            + MAX(
                COALESCE(cab."TotalExpns", 0)
                - COALESCE(frete."FreteLancado", 0)
                + COALESCE(frete."FreteEsperado", 0)
            ),
            2
        ),
        ROUND(MAX(cab."DocTotal"), 2),
        "Tolerancia_Arredondamento_Desonerado"(
            SUM(COALESCE(linha."Quantity", 0)), COUNT(1))
    INTO
        valorNegociado,
        totalDocumento,
        toleranciaResiduo
    FROM "OINV" cab
    INNER JOIN "INV1" linha ON linha."DocEntry" = cab."DocEntry"
    INNER JOIN "OUSG" usg ON usg."ID" = linha."Usage"
    LEFT JOIN (
        SELECT d."DocEntry",
            SUM(COALESCE(d."LineTotal", 0)) AS "FreteLancado",
            SUM(
                CASE
                    WHEN COALESCE(d."U_frete_negociado", 0) > 0 THEN d."U_frete_negociado"
                    ELSE COALESCE(d."LineTotal", 0)
                END
            ) AS "FreteEsperado"
        FROM "INV3" d
        WHERE d."ExpnsCode" = 1
          AND d."DocEntry" = :list_of_cols_val_tab_del
        GROUP BY d."DocEntry"
    ) frete ON frete."DocEntry" = cab."DocEntry"
    WHERE cab."DocEntry" = :list_of_cols_val_tab_del
      AND cab."BPLId" IN (2, 4, 11, 17, 18)
      AND COALESCE(usg."FreeChrgBP", 'N') = 'N'
      AND NOT EXISTS (
          SELECT 1 FROM "OBPL" filial_cliente
          WHERE filial_cliente."DflCust" = cab."CardCode"
            AND COALESCE(filial_cliente."Disabled", 'N') = 'N'
      )
      AND COALESCE(cab."U_pedido_update", '0') <> '1'
      AND EXISTS (
          SELECT 1 FROM "INV1" linha_negociada
          WHERE linha_negociada."DocEntry" = cab."DocEntry"
            AND COALESCE(linha_negociada."U_preco_negociado", 0) > 0
      );

    IF valorNegociado IS NOT NULL
       AND ABS(ROUND(valorNegociado, 2) - ROUND(totalDocumento, 2)) > :toleranciaResiduo
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
