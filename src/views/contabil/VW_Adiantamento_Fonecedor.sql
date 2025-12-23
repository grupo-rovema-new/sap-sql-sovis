CREATE OR REPLACE VIEW "VW_Adiantamento_Fonecedor" AS
(((SELECT
    O."DocEntry"  AS "AdiantDocEntry",
    O."CardCode"  AS "CardCode",
    O."CardName"  AS "CardName",
    O."DocNum"    AS "Num_Adiantamento",
    O."DocTotal"  AS "Valor_Adiantamento",
    O."BPLId"     AS "BPLId",
    O."DocDate"   AS "DocDateBase",
    'BASE'        AS "MovTipo",
    O."DocDate"   AS "MovDate",
    'N'           AS "MovCanceled",
    CAST(NULL AS DATE) AS "MovCancelDate",
    0             AS "ValorAplicado"
FROM "ODPO" O) UNION ALL (SELECT
    O."DocEntry"  AS "AdiantDocEntry",
    O."CardCode"  AS "CardCode",
    O."CardName"  AS "CardName",
    O."DocNum"    AS "Num_Adiantamento",
    O."DocTotal"  AS "Valor_Adiantamento",
    O."BPLId"     AS "BPLId",
    O."DocDate"   AS "DocDateBase",
    'APLICACAO'   AS "MovTipo",
    P."DocDate"   AS "MovDate",
    CASE WHEN COALESCE(P."CANCELED",'N') IN ('Y','C') THEN 'Y' ELSE 'N' END AS "MovCanceled",
    P."CancelDate" AS "MovCancelDate",
    P9."DrawnSum" AS "ValorAplicado"
FROM "ODPO" O
JOIN "PCH9" P9 ON P9."BaseAbs" = O."DocEntry"
JOIN "OPCH" P  ON P."DocEntry" = P9."DocEntry"
LEFT JOIN "RPC21" D
       ON P."ObjType" = D."RefObjType"
      AND P."DocEntry" = D."RefDocEntr"
WHERE D."DocEntry" IS NULL
  AND COALESCE(P."CANCELED",'N') = 'N')) UNION ALL (SELECT
    O."DocEntry"  AS "AdiantDocEntry",
    O."CardCode"  AS "CardCode",
    O."CardName"  AS "CardName",
    O."DocNum"    AS "Num_Adiantamento",
    O."DocTotal"  AS "Valor_Adiantamento",
    O."BPLId"     AS "BPLId",
    O."DocDate"   AS "DocDateBase",
    'DEVOLUCAO'   AS "MovTipo",
    R."DocDate"   AS "MovDate",
    CASE WHEN COALESCE(R."CANCELED",'N') IN ('Y','C') THEN 'Y' ELSE 'N' END AS "MovCanceled",
    R."CancelDate" AS "MovCancelDate",
    0             AS "ValorAplicado"
FROM "ODPO" O
JOIN "DPO1" D  ON D."DocEntry" = O."DocEntry"
JOIN "RPC1" R1 ON R1."BaseEntry" = D."DocEntry"
             AND D."ObjType" = R1."BaseType"
JOIN "ORPC" R  ON R."DocEntry" = R1."DocEntry"));