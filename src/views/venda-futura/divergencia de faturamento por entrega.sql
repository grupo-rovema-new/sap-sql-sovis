-- Divergencia de faturamento por entrega - Venda Futura
--
-- Objetivo: dado um contrato de venda futura, mostrar qual entrega (nota/devolucao)
-- saiu com valor diferente do previsto.
--
-- Previsto por documento:
--   produtos = SUM(Quantity * U_preco_negociado) das linhas
--   frete    = frete do contrato rateado pela proporcao dos produtos daquela entrega
--              (mesmo rateio feito pela aplicacao em PedidoRetirada.kt)
-- Faturado por documento:
--   produtos = DocTotal - TotalExpns   (o frete vai como despesa adicional, dentro do DocTotal)
--   frete    = TotalExpns
--
-- Devolucao entra com sinal negativo, entao a soma de "DiferencaTotal" bate com a
-- diferenca do contrato na consulta "contratos entregues com erro no faturamento.sql".
--
-- Filtro: so entram notas com U_entrega_vf = '1' (marcado pela aplicacao na entrega,
-- PedidoRetirada.kt) - notas do contrato que nao sao entrega ficam de fora.
-- A devolucao NAO usa esse filtro de proposito: devolucao avulsa vinculada depois ao
-- contrato (ContratoVendaFuturaController / VincularDevolucao) nao tem a flag marcada e
-- sumiria da conferencia.
--
-- Ressalvas:
--  - o rateio do frete e arredondado a cada entrega (HALF_DOWN, 2 casas);
--    diferencas de R$ 0,01-0,02 em "DiferencaFrete" sao arredondamento, nao erro.
--  - para devolucao o frete esperado usa o mesmo rateio; se a devolucao nao copiar a
--    despesa adicional da nota original, "DiferencaFrete" aparece com o valor cheio do
--    frete nessa linha - nesse caso zerar o esperado para Tipo = 'DEVOLUCAO'.


-- =====================================================================
-- 1) QUAL ENTREGA DIVERGIU  (informar o DocEntry do contrato em "parametro")
-- =====================================================================

WITH parametro AS (
    SELECT 161 AS "Contrato" FROM DUMMY          -- <<< DocEntry do contrato aqui
),

contrato AS (
    SELECT
        vf."DocEntry",
        vf."DocNum",
        COALESCE(vf."U_valorFrete", 0)                     AS "FreteContrato",
        SUM(l."U_precoNegociado" * l."U_quantity")         AS "ProdutosContrato"
    FROM "@AR_CONTRATO_FUTURO" vf
    INNER JOIN "@AR_CF_LINHA" l ON l."DocEntry" = vf."DocEntry"
    INNER JOIN parametro p      ON p."Contrato" = vf."DocEntry"
    GROUP BY vf."DocEntry", vf."DocNum", vf."U_valorFrete"
),

docs AS (
    SELECT
        'NOTA'                                  AS "Tipo",
        n."DocEntry", n."DocNum", n."DocDate", n."U_entrega_vf" AS "EntregaVF",
        COALESCE(n."TotalExpns", 0)                        AS "Frete",
        n."DocTotal" - COALESCE(n."TotalExpns", 0)         AS "Produtos"
    FROM OINV n
    INNER JOIN parametro p ON n."U_venda_futura" = TO_NVARCHAR(p."Contrato")
    WHERE n."CANCELED" = 'N'
      AND n."U_entrega_vf" = '1'          -- so notas de entrega de venda futura

    UNION ALL

    SELECT
        'DEVOLUCAO',
        d."DocEntry", d."DocNum", d."DocDate", d."U_entrega_vf",
        -COALESCE(d."TotalExpns", 0),
        -(d."DocTotal" - COALESCE(d."TotalExpns", 0))
    FROM ORIN d
    INNER JOIN parametro p ON d."U_venda_futura" = TO_NVARCHAR(p."Contrato")
    WHERE d."CANCELED" = 'N'
),

linhas AS (
    SELECT 'NOTA' AS "Tipo", l."DocEntry",
           SUM(l."Quantity" * COALESCE(l."U_preco_negociado", 0))  AS "ProdutosPrevisto"
    FROM INV1 l
    INNER JOIN docs dd ON dd."Tipo" = 'NOTA' AND dd."DocEntry" = l."DocEntry"
    GROUP BY l."DocEntry"

    UNION ALL

    SELECT 'DEVOLUCAO', l."DocEntry",
           -SUM(l."Quantity" * COALESCE(l."U_preco_negociado", 0))
    FROM RIN1 l
    INNER JOIN docs dd ON dd."Tipo" = 'DEVOLUCAO' AND dd."DocEntry" = l."DocEntry"
    GROUP BY l."DocEntry"
)

SELECT
    c."DocNum"                                                       AS "Contrato",
    d."Tipo",
    d."DocNum"                                                       AS "Documento",
    d."DocDate"                                                      AS "Data",
    d."EntregaVF",

    ROUND(li."ProdutosPrevisto", 2)                                  AS "ProdutosPrevisto",
    ROUND(d."Produtos", 2)                                           AS "ProdutosFaturado",
    ROUND(d."Produtos" - li."ProdutosPrevisto", 2)                   AS "DiferencaProdutos",

    ROUND(c."FreteContrato" * li."ProdutosPrevisto"
          / NULLIF(c."ProdutosContrato", 0), 2)                      AS "FreteEsperado",
    ROUND(d."Frete", 2)                                              AS "FreteFaturado",
    ROUND(d."Frete" - c."FreteContrato" * li."ProdutosPrevisto"
          / NULLIF(c."ProdutosContrato", 0), 2)                      AS "DiferencaFrete",

    ROUND(li."ProdutosPrevisto"
          + c."FreteContrato" * li."ProdutosPrevisto"
            / NULLIF(c."ProdutosContrato", 0), 2)                    AS "TotalEsperado",
    ROUND(d."Produtos" + d."Frete", 2)                               AS "TotalFaturado",
    ROUND((d."Produtos" + d."Frete")
          - (li."ProdutosPrevisto"
             + c."FreteContrato" * li."ProdutosPrevisto"
               / NULLIF(c."ProdutosContrato", 0)), 2)                AS "DiferencaTotal"

FROM docs d
INNER JOIN linhas   li ON li."Tipo" = d."Tipo" AND li."DocEntry" = d."DocEntry"
CROSS JOIN contrato c
ORDER BY d."DocDate", d."DocNum";


-- =====================================================================
-- 2) DRILL-DOWN POR ITEM  (informar o DocNum da nota encontrada acima)
-- =====================================================================

SELECT
    n."DocNum"                                              AS "Nota",
    l."LineNum",
    l."ItemCode",
    l."Dscription",
    l."Quantity",
    l."U_preco_negociado"                                   AS "PrecoNegociado",
    l."PriceBefDi"                                          AS "PrecoNota",
    l."DiscPrcnt"                                           AS "DescontoPct",
    ROUND(l."Quantity" * COALESCE(l."U_preco_negociado", 0), 2) AS "Previsto",
    ROUND(l."LineTotal", 2)                                 AS "Faturado",
    ROUND(l."LineTotal" - l."Quantity" * COALESCE(l."U_preco_negociado", 0), 2) AS "Diferenca"
FROM OINV n
INNER JOIN INV1 l ON l."DocEntry" = n."DocEntry"
WHERE n."DocNum" = 61534                                    -- <<< DocNum da nota aqui
ORDER BY l."LineNum";
