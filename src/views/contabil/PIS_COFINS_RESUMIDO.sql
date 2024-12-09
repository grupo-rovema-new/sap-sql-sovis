CREATE OR REPLACE VIEW PIS_COFINS_RESUMIDO AS (
SELECT 
    "BPLId",
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
DISTINCT 
    mf."DocEntry",
    mf."Serial",
    mf."DocLanc" AS "DtLancamento",
    FILIAL."BPLId",
    FILIAL."BPLName",
    UTILIZACAO."Usage",
    UTILIZACAO."ID",
    'PIS' AS "TaxType",
    "AliqPIS" AS "PIS",
    0 AS "COFINS",
    "ValorPIS" AS "Total"
FROM "MovFiscal" MF
LEFT JOIN "Entidade" E ON E."ID" = MF."Entidade"
LEFT JOIN OBPL FILIAL ON FILIAL."BPLId" = E."BusinessPlaceId"
LEFT JOIN OUSG UTILIZACAO ON UTILIZACAO.ID = MF."Utilizacao"
WHERE 
   MF."Usuario" <> 222
  --  AND "BPLId" = 2

UNION ALL

SELECT 
DISTINCT 
    mf."DocEntry",
    mf."Serial",
    mf."DocLanc" AS "DtLancamento",
    FILIAL."BPLId",
    FILIAL."BPLName",
    UTILIZACAO."Usage",
    UTILIZACAO."ID",
    'COFINS' AS "TaxType",
    0 "PIS",
    "AliqCOFINS" AS "COFINS",
    "ValorCOFINS" AS "Total"
FROM "MovFiscal" MF
LEFT JOIN "Entidade" E ON E."ID" = MF."Entidade"
LEFT JOIN OBPL FILIAL ON FILIAL."BPLId" =E."BusinessPlaceId"
LEFT JOIN OUSG UTILIZACAO ON UTILIZACAO.ID = MF."Utilizacao"
WHERE 
   mf."Usuario" <> 222
    --AND "BPLId" = 2

)
WHERE 
"Total" > 0
GROUP BY 
"BPLId",
    "BPLName",
    "Usage",
    "ID",
    "TaxType",
    "PIS",
    "COFINS",
    "DtLancamento"
    )