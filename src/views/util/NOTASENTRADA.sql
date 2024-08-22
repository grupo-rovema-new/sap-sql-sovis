CREATE OR REPLACE VIEW NOTASENTRADA AS
WITH LineTotals_OPCH AS (
    SELECT
        T0."DocEntry",
        T0."DocNum",
        T1."AcctCode",
        T1."OcrCode2",
        SUM(T1."LineTotal") AS "TotalNota"
    FROM
        OPCH T0
    INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
    WHERE
        T0."CANCELED" <> 'C'
    GROUP BY
        T0."DocEntry",
        T0."DocNum",
        T1."AcctCode",
        T1."OcrCode2"
),
LineTotals_OPDN AS (
    SELECT
        T0."DocEntry",
        T0."DocNum",
        T1."AcctCode",
        T1."OcrCode2",
        SUM(T1."LineTotal") AS "TotalNota"
    FROM
        OPDN T0
    INNER JOIN PDN1 T1 ON T0."DocEntry" = T1."DocEntry"
    WHERE
        T0."CANCELED" <> 'C'
    GROUP BY
        T0."DocEntry",
        T0."DocNum",
        T1."AcctCode",
        T1."OcrCode2"
)
SELECT
    T0."DocEntry",
    T0."DocNum",
    T0."CardCode",
    T0."CardName" AS "Parceiro de Negócio",
    T0."Serial" AS "Nº NF",
    T0."SeriesStr" AS "Série",
    LT."TotalNota" AS "Total da Nota",
    CASE
        WHEN T0."DocStatus" = 'C' AND T0."CANCELED" = 'Y' OR T0."CANCELED" = 'C' THEN 'Cancelado'
        WHEN T0."PaidSum" = T0."DocTotal" THEN 'Pago'
        WHEN T0."PaidSum" < T0."DocTotal" AND T0."PaidSum" <> 0 THEN 'Pago parcial'
        ELSE 'Aberto'
    END AS "Status",
    T0."DocDate" AS "Data de Lançamento",
    T0."BPLId",
    T2."USER_CODE",
    T2."U_NAME" AS "Colaborador",
    T0."BPLName" AS "Filial",
    T0."DocDueDate" AS "Data de Vencimento",
    'Nota de entrada' AS "Tipo de documento",
    T0."TaxDate" AS "Data de Emissão",
    (
        SELECT MAX(T2."Usage")
        FROM PCH1
        INNER JOIN OUSG T2 ON PCH1."Usage" = T2."ID"
        WHERE PCH1."DocEntry" = T0."DocEntry"
    ) AS "Utilização",
    (
        SELECT MAX(T2."ID")
        FROM PCH1
        INNER JOIN OUSG T2 ON PCH1."Usage" = T2."ID"
        WHERE PCH1."DocEntry" = T0."DocEntry"
    ) AS "IDUtil",
    LT."OcrCode2" AS "Centro de custo",
    (
        SELECT o."PrcName" FROM OPRC o WHERE o."PrcCode" = LT."OcrCode2"
    ) AS "Nome centro de custo",
    LT."AcctCode" AS "Conta",
    (
        SELECT o2."AcctName" FROM OACT o2 WHERE o2."AcctCode" = LT."AcctCode"
    ) AS "Nome da conta"
FROM
    OPCH T0
INNER JOIN LineTotals_OPCH LT ON T0."DocEntry" = LT."DocEntry"
INNER JOIN OUSR T2 ON T0."UserSign" = T2."USERID"
WHERE
    T0."CANCELED" <> 'C'
UNION ALL

SELECT
    T0."DocEntry",
    T0."DocNum",
    T0."CardCode",
    T0."CardName" AS "Parceiro de Negócio",
    T0."Serial" AS "Nº NF",
    T0."SeriesStr" AS "Série",
    LT."TotalNota" AS "Total da Nota",
    CASE
        WHEN T0."DocStatus" = 'C' AND T0."CANCELED" = 'Y' OR T0."CANCELED" = 'C' THEN 'Cancelado'
        ELSE 'Aberto'
    END AS "Status",
    T0."DocDate" AS "Data de Lançamento",
    T0."BPLId",
    T1."USER_CODE",
    T1."U_NAME" AS "Colaborador",
    T0."BPLName" AS "Filial",
    T0."DocDueDate" AS "Data de Vencimento",
    'Recebimento de mercadoria' AS "Tipo de documento",
    T0."TaxDate" AS "Data de Emissão",
    (
        SELECT MAX(T2."Usage")
        FROM PDN1
        INNER JOIN OUSG T2 ON PDN1."Usage" = T2."ID"
        WHERE PDN1."DocEntry" = T0."DocEntry"
    ) AS "Utilização",
    (
        SELECT MAX(T2."ID")
        FROM PDN1
        INNER JOIN OUSG T2 ON PDN1."Usage" = T2."ID"
        WHERE PDN1."DocEntry" = T0."DocEntry"
    ) AS "IDUtil",
    LT."OcrCode2" AS "Centro de custo",
    (
        SELECT o."PrcName" FROM OPRC o WHERE o."PrcCode" = LT."OcrCode2"
    ) AS "Nome centro de custo",
    LT."AcctCode" AS "Conta",
    (
        SELECT o2."AcctName" FROM OACT o2 WHERE o2."AcctCode" = LT."AcctCode"
    ) AS "Nome da conta"
FROM
    OPDN T0
INNER JOIN LineTotals_OPDN LT ON T0."DocEntry" = LT."DocEntry"
INNER JOIN OUSR T1 ON T0."UserSign" = T1."USERID"
WHERE
    T0."CANCELED" <> 'C'
UNION ALL

SELECT DISTINCT
    T0."DocEntry",
    T0."DocNum",
    T0."CardCode",
    T0."CardName" AS "Parceiro de Negócio",
    T0."Serial" AS "Nº NF",
    T0."SeriesStr" AS "Série",
    T0."DocTotal" AS "Total da Nota",
    CASE
        WHEN T0."DocStatus" = 'C' AND T0."CANCELED" = 'Y' OR T0."CANCELED" = 'C' THEN 'Cancelado'
        ELSE 'Aberto'
    END AS "Status",
    T0."DocDate" AS "Data de Lançamento",
    T0."BPLId",
    T1."USER_CODE",
    T1."U_NAME" AS "Colaborador",
    T0."BPLName" AS "Filial",
    T0."DocDueDate" AS "Data de Vencimento",
    'Dev. Nota Fiscal Saída' AS "Tipo de documento",
    T0."TaxDate" AS "Data de Emissão",
    (
        SELECT MAX(T2."Usage")
        FROM RIN1
        INNER JOIN OUSG T2 ON RIN1."Usage" = T2."ID"
        WHERE RIN1."DocEntry" = T0."DocEntry"
    ) AS "Utilização",
    (
        SELECT MAX(T2."ID")
        FROM RIN1
        INNER JOIN OUSG T2 ON RIN1."Usage" = T2."ID"
        WHERE RIN1."DocEntry" = T0."DocEntry"
    ) AS "IDUtil",
    L."OcrCode2" AS "Centro de custo",
    (
        SELECT o."PrcName" FROM OPRC o WHERE o."PrcCode" = L."OcrCode2"
    ) AS "Nome centro de custo",
    L."AcctCode" AS "Conta",
    (
        SELECT o2."AcctName" FROM OACT o2 WHERE o2."AcctCode" = L."AcctCode"
    ) AS "Nome da conta"
FROM
    ORIN T0
INNER JOIN RIN1 L ON T0."DocEntry" = L."DocEntry"
INNER JOIN OUSR T1 ON T0."UserSign" = T1."USERID"
WHERE
    T0."CANCELED" <> 'C'