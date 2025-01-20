CREATE OR REPLACE VIEW PIS_COFINS_RESUMIDO AS
SELECT 
    "BPLId",
    "CST",
    "DtLancamento",
    "BPLName",
    "Usage",
    "ID",
    "TaxType",
    "PIS",
    "COFINS",
    SUM("Total") AS Total
FROM (
SELECT
    mf."DOC_ENTRY",
    mf."CST",
    mf."NOTA",
    mf."DATA_DE_LANCAMENTO" AS "DtLancamento",
    mf."ID_FILIAL" AS "BPLId",
    FILIAL."BPLName",
    mf."UTILIZACAO" AS "Usage",
    mf."ID_UTILIZACAO" AS ID,
    'PIS' AS "TaxType",
    "Alicota PIS" AS "PIS",
     0 AS "COFINS",
    "PIS_PASEP" AS "Total"
FROM BASE_PIS_COFINS MF
LEFT JOIN OBPL FILIAL ON FILIAL."BPLId" = mf."ID_FILIAL"

  

UNION ALL

SELECT  
    mf."DOC_ENTRY",
    mf."CST",
    mf."NOTA",
    mf."DATA_DE_LANCAMENTO" AS "DtLancamento",
    mf."ID_FILIAL",
    FILIAL."BPLName",
    mf."UTILIZACAO" AS "Usage",
    mf."ID_UTILIZACAO" AS "ID",
    'COFINS' AS "TaxType",
    0 "PIS",
    "Alicota COFINS" AS "COFINS",
    "COFINS" AS "Total"
FROM "BASE_PIS_COFINS" MF
LEFT JOIN OBPL FILIAL ON FILIAL."BPLId" = mf."ID_FILIAL"


)
WHERE 
"Total" > 0
GROUP BY 
"BPLId",
"CST",
    "BPLName",
    "Usage",
    "ID",
    "TaxType",
    "PIS",
    "COFINS",
    "DtLancamento";