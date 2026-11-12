  WITH contrato AS (
      SELECT
          vf."DocEntry"                         AS "Contrato",
          vf."DocNum"                           AS "ContratoNum",
          vf."U_status"                         AS "Status",
          vf."U_cardCode"                       AS "CardCode",
          vf."U_cardName"                       AS "Cliente",
          vf."U_orderDocEntry"                  AS "PedidoOrigemDocEntry",
          vf."U_filial"                         AS "Filial",
          filial."BPLName"                      AS "NomeFilial",
          vf."U_valorFrete"                     AS "FreteContrato",
          SUM(linha."U_precoNegociado" * linha."U_quantity") AS "ValorProdutosContrato"
      FROM "@AR_CONTRATO_FUTURO" vf
      INNER JOIN "@AR_CF_LINHA" linha
          ON linha."DocEntry" = vf."DocEntry"
      LEFT JOIN OBPL filial
          ON filial."BPLId" = vf."U_filial"
      GROUP BY
          vf."DocEntry",
          vf."DocNum",
          vf."U_status",
          vf."U_cardCode",
          vf."U_cardName",
          vf."U_orderDocEntry",
          vf."U_filial",
          filial."BPLName",
          vf."U_valorFrete"
  ),

  notas AS (
      SELECT
          nf."U_venda_futura" AS "Contrato",
          SUM(nf."DocTotal") AS "ValorProdutosFaturado",
          COUNT(DISTINCT nf."DocEntry") AS "QtdNotas",
          STRING_AGG(TO_NVARCHAR(nf."DocNum"), ', ') AS "Notas"
      FROM OINV nf
      WHERE
          nf."CANCELED" = 'N'
          AND nf."U_venda_futura" IS NOT NULL
          AND nf."DocTotal" > 0
      GROUP BY
          nf."U_venda_futura"
  ),

  devolucoes AS (
      SELECT
          dev."U_venda_futura" AS "Contrato",
          SUM(dev."DocTotal") AS "ValorProdutosDevolvido",
          COUNT(DISTINCT dev."DocEntry") AS "QtdDevolucoes",
          STRING_AGG(TO_NVARCHAR(dev."DocNum"), ', ') AS "Devolucoes"
      FROM ORIN dev
      WHERE
          dev."CANCELED" = 'N'
          AND dev."U_venda_futura" IS NOT NULL
          AND dev."DocTotal" > 0
      GROUP BY
          dev."U_venda_futura"
  )

  SELECT
      c."Contrato",
      c."Status",
      c."CardCode",
      c."Cliente",
      c."Filial",
      c."NomeFilial",
      CASE
          WHEN (
              COALESCE(n."ValorProdutosFaturado", 0)
              - COALESCE(d."ValorProdutosDevolvido", 0)
          ) - (c."ValorProdutosContrato" + COALESCE(c."FreteContrato", 0)) BETWEEN 0.01 AND 0.05
          THEN 'TECNOLOGIA'
          WHEN (
              COALESCE(n."ValorProdutosFaturado", 0)
              - COALESCE(d."ValorProdutosDevolvido", 0)
          ) - (c."ValorProdutosContrato" + COALESCE(c."FreteContrato", 0)) BETWEEN -0.05 AND -0.01
          THEN 'TECNOLOGIA'
          ELSE 'UNIDADE'
      END AS "Responsavel",

      c."ValorProdutosContrato" + COALESCE(c."FreteContrato", 0) AS "ValorTotalContrato",
      COALESCE(n."ValorProdutosFaturado", 0) - COALESCE(d."ValorProdutosDevolvido", 0) AS "ValorFaturadoLiquido",

      (
          COALESCE(n."ValorProdutosFaturado", 0)
          - COALESCE(d."ValorProdutosDevolvido", 0)
      ) - (c."ValorProdutosContrato" + COALESCE(c."FreteContrato", 0)) AS "DiferencaProdutos",

      n."QtdNotas",
      n."Notas",
      d."QtdDevolucoes",
      d."Devolucoes"

  FROM contrato c
  LEFT JOIN notas n
      ON n."Contrato" = c."Contrato"
  LEFT JOIN devolucoes d
      ON d."Contrato" = c."Contrato"
  WHERE
      c."Status" = 'entregue'
      AND (
          COALESCE(n."ValorProdutosFaturado", 0)
          - COALESCE(d."ValorProdutosDevolvido", 0)
      ) > c."ValorProdutosContrato"
      AND (
          (
              (
                  COALESCE(n."ValorProdutosFaturado", 0)
                  - COALESCE(d."ValorProdutosDevolvido", 0)
              ) - (c."ValorProdutosContrato" + COALESCE(c."FreteContrato", 0))
          ) >= 0.01
          OR
          (
              (
                  COALESCE(n."ValorProdutosFaturado", 0)
                  - COALESCE(d."ValorProdutosDevolvido", 0)
              ) - (c."ValorProdutosContrato" + COALESCE(c."FreteContrato", 0))
          ) <= -0.01
      )
  ORDER BY
      "DiferencaProdutos" DESC;
      
     
     