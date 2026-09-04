-- Devolucao duplicada por nota - Venda Futura
--
-- Objetivo: achar as notas de entrega de venda futura que receberam MAIS DE UMA
-- devolucao (ORIN). Ja apareceu um caso de nota devolvida duas vezes; esta
-- consulta varre a base para saber se existem outros.
--
-- Por que isso vira problema financeiro:
--   ReclassificacaoEntregaVendaFuturaSchedule.estorno() (sap-service) itera por
--   DEVOLUCAO, nao por nota: para cada ORIN com U_venda_futura preenchido e
--   U_conciliar_automatico = 1 ele lanca o VFDV e, se a entrega ja tinha
--   apropriacao de adiantamento, cria um NOVO adiantamento de devolucao
--   (ODPI com U_TX_DocEntryRef = DocEntry da devolucao - ver
--   EstornoReclassificacaoVendaFuturaService.estornar).
--   A idempotencia e por devolucao (U_TX_DocEntryRef), nao por nota: duas
--   devolucoes da MESMA nota geram DOIS creditos no contrato e o cliente fica
--   com saldo a mais. O fluxo /vincular-devolucao do controller barra esse
--   cenario ("provavel cancelamento em duplicidade"); o schedule nao barra.
--
-- Como ler o resultado:
--   "QtdDevolucoes"         > 1   -> a nota tem mais de uma devolucao
--   "ExcedenteValor"        > 0   -> devolveu acima do valor da nota (duplicidade certa)
--   "QtdAdiantamentosDev"   > 1   -> credito em dobro no contrato (o dano financeiro)
--   "Diagnostico"                 -> classificacao pronta das duas situacoes acima
--
-- Filtros e ressalvas:
--   - o vinculo nota x devolucao sai das linhas RIN1 (BaseType = 13 = OINV), ou
--     seja, pega a devolucao COPIADA da nota. Devolucao avulsa (lancada solta,
--     sem documento base) nao aparece aqui - para essas use a consulta 2.
--   - ORIN com SeqCode = 1 e linhas com BaseType = 203 ficam fora: sao estorno de
--     adiantamento, nao devolucao de mercadoria.
--   - linhas com Usage = 79 (venda-futura.utilizacao.baixa) e o item FIN0000002
--     (venda-futura.adiantamento-item) tambem ficam fora, mesma razao.
--   - documentos cancelados ('Y' e 'C') ficam fora dos dois lados.
--   - "ValorDevolvido" soma o DocTotal do cabecalho da devolucao. Se uma mesma
--     devolucao tiver linhas de duas notas diferentes, o total dela conta nas
--     duas - nesse caso compare por "ValorLinhasDevolvido", que e por linha.


-- =====================================================================
-- 1) NOTAS DE VENDA FUTURA COM MAIS DE UMA DEVOLUCAO
-- =====================================================================

WITH adt_dev AS (
    -- adiantamento de devolucao criado pelo estorno: 1 por devolucao (esperado)
    SELECT
        a."U_TX_DocEntryRef"                            AS "DevEntry",
        COUNT(*)                                        AS "QtdAdt",
        SUM(a."DocTotal")                               AS "ValorAdt"
    FROM ODPI a
    WHERE a."CANCELED" = 'N'
      AND IFNULL(a."U_TX_DocEntryRef", 0) > 0
      AND (   IFNULL(a."Comments", '') LIKE '%adiantamento de devolucao%'
           OR IFNULL(a."JrnlMemo", '') LIKE '%adiantamento de devolucao%' )
    GROUP BY a."U_TX_DocEntryRef"
),

dev_linha AS (
    -- linhas de mercadoria das devolucoes, agrupadas pela nota de origem
    SELECT
        l."BaseEntry"                                   AS "NotaEntry",
        r."DocEntry"                                    AS "DevEntry",
        SUM(l."LineTotal")                              AS "ValorLinhas",
        SUM(l."Quantity")                               AS "QtdLinhas"
    FROM ORIN r
    INNER JOIN RIN1 l ON l."DocEntry" = r."DocEntry"
    WHERE r."CANCELED" = 'N'
      AND IFNULL(r."SeqCode", 0) <> 1        -- exclui estorno de adiantamento
      AND l."BaseType" = 13                  -- copiada de nota fiscal de saida (OINV)
      AND IFNULL(TO_NVARCHAR(l."Usage"), '') <> '79'  -- exclui utilizacao de baixa
      AND IFNULL(l."ItemCode", '') <> 'FIN0000002'
    GROUP BY l."BaseEntry", r."DocEntry"
),

dev AS (
    SELECT
        dl."NotaEntry",
        dl."DevEntry",
        dl."ValorLinhas",
        dl."QtdLinhas",
        r."DocNum"                                      AS "DevDocNum",
        CASE WHEN r."Serial" IS NOT NULL AND r."Serial" <> 0
             THEN TO_NVARCHAR(r."Serial")
             ELSE TO_NVARCHAR(r."DocNum") END           AS "DevNF",
        r."DocDate"                                     AS "DevData",
        r."DocTotal"                                    AS "DevTotal",
        IFNULL(ad."QtdAdt", 0)                          AS "QtdAdt",
        IFNULL(ad."ValorAdt", 0)                        AS "ValorAdt"
    FROM dev_linha dl
    INNER JOIN ORIN r    ON r."DocEntry"  = dl."DevEntry"
    LEFT  JOIN adt_dev ad ON ad."DevEntry" = dl."DevEntry"
),

nota_dev AS (
    SELECT
        d."NotaEntry",
        COUNT(*)                                        AS "QtdDevolucoes",
        SUM(d."DevTotal")                               AS "ValorDevolvido",
        SUM(d."ValorLinhas")                            AS "ValorLinhasDevolvido",
        SUM(d."QtdAdt")                                 AS "QtdAdiantamentosDev",
        SUM(d."ValorAdt")                               AS "ValorAdiantamentosDev",
        MIN(d."DevData")                                AS "PrimeiraDevolucao",
        MAX(d."DevData")                                AS "UltimaDevolucao",
        STRING_AGG(
            d."DevNF" || ' (' || TO_NVARCHAR(d."DevData", 'DD/MM/YYYY')
                      || ' - ' || TO_NVARCHAR(ROUND(d."DevTotal", 2)) || ')',
            '  |  ' ORDER BY d."DevData", d."DevDocNum")  AS "Devolucoes"
    FROM dev d
    GROUP BY d."NotaEntry"
    HAVING COUNT(*) > 1
)

SELECT
    vf."DocEntry"                                       AS "Contrato",
    vf."U_status"                                       AS "StatusContrato",
    f."BPLName"                                         AS "Filial",
    n."CardCode",
    n."CardName",
    v."SlpName"                                         AS "Vendedor",

    n."DocNum"                                          AS "NotaDocNum",
    CASE WHEN n."Serial" IS NOT NULL AND n."Serial" <> 0
         THEN TO_NVARCHAR(n."Serial")
         ELSE TO_NVARCHAR(n."DocNum") END               AS "NotaNF",
    n."DocDate"                                         AS "DataNota",
    ROUND(n."DocTotal", 2)                              AS "ValorNota",
    n."U_vf_estornada"                                  AS "NotaEstornada",

    nd."QtdDevolucoes",
    ROUND(nd."ValorDevolvido", 2)                       AS "ValorDevolvido",
    ROUND(nd."ValorLinhasDevolvido", 2)                 AS "ValorLinhasDevolvido",
    ROUND(nd."ValorDevolvido" - n."DocTotal", 2)        AS "ExcedenteValor",

    nd."QtdAdiantamentosDev",
    ROUND(nd."ValorAdiantamentosDev", 2)                AS "ValorAdiantamentosDev",

    nd."PrimeiraDevolucao",
    nd."UltimaDevolucao",
    nd."Devolucoes",

    CASE
        WHEN nd."ValorDevolvido" - n."DocTotal" > 0.02
            THEN 'DUPLICIDADE - devolvido acima do valor da nota'
        WHEN nd."QtdAdiantamentosDev" > 1
            THEN 'DUPLICIDADE - mais de um adiantamento de devolucao (credito em dobro)'
        ELSE 'CONFERIR - devolucoes parciais dentro do valor da nota'
    END                                                 AS "Diagnostico"

FROM nota_dev nd
INNER JOIN OINV n                    ON n."DocEntry" = nd."NotaEntry"
                                    AND n."CANCELED" = 'N'
-- INNER JOIN restringe ao escopo de venda futura; troque por LEFT JOIN para ver
-- todas as notas com mais de uma devolucao, inclusive fora de venda futura.
INNER JOIN "@AR_CONTRATO_FUTURO" vf  ON TO_NVARCHAR(vf."DocEntry") = n."U_venda_futura"
LEFT  JOIN OBPL f                    ON f."BPLId"   = n."BPLId"
LEFT  JOIN OSLP v                    ON v."SlpCode" = n."SlpCode"
ORDER BY
    CASE
        WHEN nd."ValorDevolvido" - n."DocTotal" > 0.02 THEN 1
        WHEN nd."QtdAdiantamentosDev" > 1              THEN 2
        ELSE 3
    END,
    nd."UltimaDevolucao" DESC,
    vf."DocEntry";


-- =====================================================================
-- 2) VISAO POR CONTRATO - pega tambem devolucao avulsa (sem documento base)
--    Descomente para rodar. Aqui o vinculo e o proprio U_venda_futura da ORIN,
--    entao entra a devolucao avulsa que o /vincular-devolucao amarrou ao
--    contrato e que a consulta 1 nao ve (nao tem linha com BaseType = 13).
-- =====================================================================
--
--WITH entrega AS (
--    SELECT
--        n."U_venda_futura"                              AS "Contrato",
--        COUNT(*)                                        AS "QtdEntregas",
--        SUM(n."DocTotal")                               AS "ValorEntregue"
--    FROM OINV n
--    WHERE n."CANCELED" = 'N'
--      AND n."U_entrega_vf" = '1'
--    GROUP BY n."U_venda_futura"
--),
--devolucao AS (
--    SELECT
--        r."U_venda_futura"                              AS "Contrato",
--        COUNT(*)                                        AS "QtdDevolucoes",
--        SUM(r."DocTotal")                               AS "ValorDevolvido",
--        STRING_AGG(TO_NVARCHAR(r."DocNum"), ', ' ORDER BY r."DocDate") AS "DevolucoesDocNum"
--    FROM ORIN r
--    WHERE r."CANCELED" = 'N'
--      AND IFNULL(r."SeqCode", 0) <> 1
--      AND IFNULL(r."U_venda_futura", '') NOT IN ('', '0')
--    GROUP BY r."U_venda_futura"
--),
--adt_dev AS (
--    SELECT
--        a."U_venda_futura"                              AS "Contrato",
--        COUNT(*)                                        AS "QtdAdiantamentosDev",
--        SUM(a."DocTotal")                               AS "ValorAdiantamentosDev"
--    FROM ODPI a
--    WHERE a."CANCELED" = 'N'
--      AND (   IFNULL(a."Comments", '') LIKE '%adiantamento de devolucao%'
--           OR IFNULL(a."JrnlMemo", '') LIKE '%adiantamento de devolucao%' )
--    GROUP BY a."U_venda_futura"
--)
--SELECT
--    vf."DocEntry"                                       AS "Contrato",
--    vf."U_cardCode"                                     AS "CardCode",
--    vf."U_cardName"                                     AS "CardName",
--    vf."U_status"                                       AS "StatusContrato",
--    f."BPLName"                                         AS "Filial",
--    IFNULL(e."QtdEntregas", 0)                          AS "QtdEntregas",
--    ROUND(IFNULL(e."ValorEntregue", 0), 2)              AS "ValorEntregue",
--    d."QtdDevolucoes",
--    ROUND(d."ValorDevolvido", 2)                        AS "ValorDevolvido",
--    ROUND(d."ValorDevolvido" - IFNULL(e."ValorEntregue", 0), 2) AS "ExcedenteValor",
--    d."DevolucoesDocNum",
--    IFNULL(ad."QtdAdiantamentosDev", 0)                 AS "QtdAdiantamentosDev",
--    ROUND(IFNULL(ad."ValorAdiantamentosDev", 0), 2)     AS "ValorAdiantamentosDev",
--    CASE
--        WHEN d."ValorDevolvido" - IFNULL(e."ValorEntregue", 0) > 0.02
--            THEN 'DUPLICIDADE - devolvido acima do total entregue'
--        WHEN IFNULL(ad."QtdAdiantamentosDev", 0) > d."QtdDevolucoes"
--            THEN 'DUPLICIDADE - mais adiantamentos de devolucao do que devolucoes'
--        ELSE 'OK'
--    END                                                 AS "Diagnostico"
--FROM devolucao d
--INNER JOIN "@AR_CONTRATO_FUTURO" vf ON TO_NVARCHAR(vf."DocEntry") = d."Contrato"
--LEFT  JOIN entrega e                ON e."Contrato" = d."Contrato"
--LEFT  JOIN adt_dev ad               ON TO_NVARCHAR(vf."DocEntry") = ad."Contrato"
--LEFT  JOIN OBPL f                   ON f."BPLId"    = vf."U_filial"
--WHERE d."ValorDevolvido" - IFNULL(e."ValorEntregue", 0) > 0.02
--   OR IFNULL(ad."QtdAdiantamentosDev", 0) > d."QtdDevolucoes"
--ORDER BY "ExcedenteValor" DESC, vf."DocEntry";


-- =====================================================================
-- 3) DRILL-DOWN ITEM A ITEM - qtd faturada x qtd devolvida de UMA nota
--    Informe o DocEntry da nota encontrada na consulta 1.
-- =====================================================================
--
--WITH parametro AS (
--    SELECT 0 AS "NotaEntry" FROM DUMMY                  -- <<< DocEntry da nota aqui
--),
--faturado AS (
--    SELECT l."ItemCode", MAX(l."Dscription") AS "Descricao",
--           SUM(l."Quantity") AS "QtdFaturada", SUM(l."LineTotal") AS "ValorFaturado"
--    FROM INV1 l
--    INNER JOIN parametro p ON p."NotaEntry" = l."DocEntry"
--    GROUP BY l."ItemCode"
--),
--devolvido AS (
--    SELECT l."ItemCode",
--           SUM(l."Quantity") AS "QtdDevolvida", SUM(l."LineTotal") AS "ValorDevolvido",
--           STRING_AGG(TO_NVARCHAR(r."DocNum"), ', ' ORDER BY r."DocDate") AS "Devolucoes"
--    FROM RIN1 l
--    INNER JOIN ORIN r      ON r."DocEntry"  = l."DocEntry" AND r."CANCELED" = 'N'
--    INNER JOIN parametro p ON p."NotaEntry" = l."BaseEntry"
--    WHERE l."BaseType" = 13
--      AND IFNULL(r."SeqCode", 0) <> 1
--    GROUP BY l."ItemCode"
--)
--SELECT
--    f."ItemCode", f."Descricao",
--    f."QtdFaturada", ROUND(f."ValorFaturado", 2)        AS "ValorFaturado",
--    IFNULL(d."QtdDevolvida", 0)                         AS "QtdDevolvida",
--    ROUND(IFNULL(d."ValorDevolvido", 0), 2)             AS "ValorDevolvido",
--    IFNULL(d."QtdDevolvida", 0) - f."QtdFaturada"       AS "ExcedenteQtd",
--    d."Devolucoes",
--    CASE WHEN IFNULL(d."QtdDevolvida", 0) > f."QtdFaturada"
--         THEN 'DEVOLVEU MAIS DO QUE FATUROU' ELSE 'OK' END AS "Diagnostico"
--FROM faturado f
--LEFT JOIN devolvido d ON d."ItemCode" = f."ItemCode"
--ORDER BY "ExcedenteQtd" DESC, f."ItemCode";
