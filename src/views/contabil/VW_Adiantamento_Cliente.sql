CREATE OR REPLACE VIEW "VW_Adiantamento_Cliente" AS
(
    /* 1) BASE: Adiantamento */
    SELECT
        O."DocEntry"  AS "AdiantDocEntry",
        O."CardCode",
        O."CardName",
        O."DocNum"    AS "Num_Adiantamento",
        O."DocTotal"  AS "Valor_Adiantamento",
        O."BPLId",
        O."DocDate"   AS "DocDateBase",
        'BASE'        AS "MovTipo",
        O."DocDate"   AS "MovDate",
        'N'           AS "MovCanceled",
        CAST(NULL AS DATE) AS "MovCancelDate",
        0             AS "ValorAplicado"
    FROM ODPI O

    UNION ALL

    /* 2) APLICAÇÃO: NF que aplicou o adiantamento */
    SELECT
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
        I."CancelDate" AS "MovCancelDate",
        I9."DrawnSum" AS "ValorAplicado"
    FROM ODPI O
    JOIN INV9 I9 ON I9."BaseAbs" = O."DocEntry"
    JOIN OINV I  ON I."DocEntry" = I9."DocEntry"

    UNION ALL

    /* 3) DEVOLUÇÃO: NC criada a partir do adiantamento (seu cenário atual) */
    SELECT
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
        C."CancelDate" AS "MovCancelDate",
        0 AS "ValorAplicado"
    FROM ODPI O
    JOIN DPI1 D  ON D."DocEntry" = O."DocEntry"
    JOIN RIN1 C1 ON C1."BaseEntry" = D."DocEntry" AND D."ObjType" = C1."BaseType"
    JOIN ORIN C  ON C."DocEntry" = C1."DocEntry"

   UNION ALL
   
    SELECT
        O."DocEntry",
        O."CardCode",
        O."CardName",
        O."DocNum",
        O."DocTotal",
        O."BPLId",
        O."DocDate",
        'DEVOLUCAO_APLICACAO' AS "MovTipo",
        I."DocDate" AS "MovDate",
        CASE WHEN COALESCE(I."CANCELED",'N') IN ('Y','C') THEN 'Y' ELSE 'N' END AS "MovCanceled",
        I."CancelDate" AS "MovCancelDate",
        -I9."DrawnSum" AS "ValorAplicado"
    FROM ODPI O
    JOIN INV9 I9 ON I9."BaseAbs" = O."DocEntry"
    JOIN OINV I  ON I."DocEntry" = I9."DocEntry"
    LEFT JOIN RIN21 D 
       ON I."ObjType" = D."RefObjType"
      AND I."DocEntry" = D."RefDocEntr"
    LEFT JOIN RIN9 ADD ON D."DocEntry" = ADD."DocEntry" 
    LEFT JOIN ORIN DE 
     ON D."DocEntry" = DE."DocEntry" 
WHERE D."DocEntry" IS NOT NULL
AND DE.CANCELED = 'N'
AND ADD."DocEntry" IS NOT NULL

);
