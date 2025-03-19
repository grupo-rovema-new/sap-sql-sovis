CREATE OR REPLACE VIEW GGFAPURADO AS
SELECT
    JDT1."BPLId",
    pai."AcctName" pai,
    SUM(JDT1."Debit"-JDT1."Credit") AS "valor",
    MONTH(OJDT."RefDate") AS mes,
    YEAR(OJDT."RefDate") AS ano,
    YEAR(OJDT."RefDate") || '-' ||MONTH(OJDT."RefDate") AS "ano-mes"
FROM OJDT
INNER JOIN JDT1 ON OJDT."TransId" = JDT1."TransId"
INNER JOIN OACT ON JDT1."Account" = OACT."AcctCode"
INNER JOIN OACT AS pai ON pai."AcctCode" = OACT."FatherNum"
WHERE
    OJDT."TransType" NOT IN (60)
    AND "Account" LIKE '4.1.2%'
GROUP BY
    JDT1."BPLId",
    pai."AcctName",
    YEAR(OJDT."RefDate") || '-' ||MONTH(OJDT."RefDate"),
    MONTH(OJDT."RefDate"),
    YEAR(OJDT."RefDate");