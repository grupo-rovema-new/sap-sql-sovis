
CREATE OR REPLACE VIEW RESUMO_NATUREZA_OPERACAO AS
SELECT 
    "BPLId",
    "CST",
    "DtLancamento",
    "BPLName",
    "Usage",
    "ID",
    COUNT(DISTINCT "DocEntry" ) AS "N NOTAS",
    SUM("VL_Mercadoria") AS VL_Mercadoria,
    SUM("VL_Desconto") AS VL_Desconto,
    SUM("Total") AS Total,
    0 AS "Monofasico",
    0 AS "Aliquota_0",
    0 AS "Suspenso",
    0 AS "Nao_incidencia",
    SUM("ICMS") AS ICMS,
    SUM("IPI") AS IPI,
    SUM("ISS") AS ISS,
    SUM("Base_de_Calculo") AS Base_de_Calculo,
    SUM("PIS_PASEP") AS PIS_PASEP,
    SUM("COFINS") AS COFINS,
    "TIPO"
FROM (
SELECT 
--DISTINCT 
    mf."DOC_ENTRY" AS "DocEntry",
    mf."CST",
    MF."DATA_DE_LANCAMENTO" AS "DtLancamento" ,
    mf."NOTA",
    mf."ID_FILIAL" AS "BPLId",
    FILIAL."BPLName",
    mf."UTILIZACAO" AS "Usage",
    mf."ID_UTILIZACAO" AS "ID",
    mf."VALOR_MERCADORIA" AS "VL_Mercadoria",
    mf."VALOR_DESCONTOS" AS "VL_Desconto",
    mf."VALOR_MERCADORIA" - mf."VALOR_DESCONTOS" AS "Total",
    0 AS "Monofasico",
    0 AS "Aliquota_0",
    0 AS "Suspenso",
    0 AS "Nao_incidencia",
    mf."ICMS" AS "ICMS",
    mf."IPI" AS "IPI",
    mf."ISS" AS "ISS",
    mf."Base de calculo PIS" AS "Base_de_Calculo",
    mf."PIS_PASEP" AS "PIS_PASEP",
    mf."COFINS" AS "COFINS",
    mf."TIPO"
FROM "BASE_PIS_COFINS" MF
LEFT JOIN OBPL FILIAL ON FILIAL."BPLId" = mf."ID_FILIAL"

)
GROUP BY 
"BPLId",
"CST",
    "BPLName",
    "Usage",
    "ID",
    "TIPO",
   "DtLancamento";