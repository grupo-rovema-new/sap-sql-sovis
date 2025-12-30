CREATE OR REPLACE VIEW "VW_Adiantamento_Cliente" AS
(((SELECT
      O."DocEntry" AS "AdiantDocEntry",
      O."CardCode",
      O."CardName", 
      O."DocNum" AS "Num_Adiantamento",
      O."DocTotal" AS "Valor_Adiantamento",
      O."BPLId",
      O."DocDate" AS "DocDateBase",
      'BASE' AS "MovTipo",
      O."DocDate" AS "MovDate",
      'N' AS "MovCanceled",
      CAST(NULL AS DATE) AS "MovCancelDate",
      0 AS "ValorAplicado"
    FROM ODPI O) UNION ALL (SELECT
      O."DocEntry",
      O."CardCode", 
      O."CardName",
      O."DocNum",
      O."DocTotal",
      O."BPLId",
      O."DocDate",
      'APLICACAO' AS "MovTipo",
      I."DocDate" AS "MovDate",
      CASE WHEN COALESCE(I."CANCELED",'N') IN ('Y','C') THEN 'Y' ELSE 'N' END AS "MovCanceled",
      COALESCE(I."CancelDate", I."CancelDate", I."CancelDate") AS "MovCancelDate",
      I9."DrawnSum" AS "ValorAplicado"
    FROM ODPI O
    JOIN INV9 I9 ON I9."BaseAbs" = O."DocEntry"  -- INV9: Linha de adiantamento em notas fiscais de venda
    JOIN OINV I ON I."DocEntry" = I9."DocEntry")) UNION ALL (SELECT
      O."DocEntry",
      O."CardCode",
      O."CardName", 
      O."DocNum",
      O."DocTotal",
      O."BPLId",
      O."DocDate",
      'DEVOLUCAO' AS "MovTipo",
      C."DocDate" AS "MovDate",
      CASE WHEN COALESCE(C."CANCELED",'N') IN ('Y','C') THEN 'Y' ELSE 'N' END AS "MovCanceled",
      COALESCE(C."CancelDate", C."CancelDate", C."CancelDate") AS "MovCancelDate",
      0 AS "ValorAplicado"
    FROM ODPI O
    JOIN DPI1 D ON D."DocEntry" = O."DocEntry"    -- DPI1: Linhas do adiantamento de cliente
    JOIN RIN1 C1 ON C1."BaseEntry" = D."DocEntry" AND D."ObjType" = C1."BaseType"  -- RIN1: Linhas da nota de crédito
    JOIN ORIN C ON C."DocEntry" = C1."DocEntry"));