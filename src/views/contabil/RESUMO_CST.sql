CREATE OR REPLACE VIEW RESUMO_CST AS
SELECT 
    "BPLId",
    "BPLName",
    "CST",
    "DtLancamento" ,
    SUM("VL_Mercadoria") AS "VL Mercadoria",
    SUM("VL_Desconto") AS "VL Descontos(-)",
    SUM("Total") AS "VL Total",
    SUM("Base_de_Calculo") AS "Base de Cálculo",
    SUM("PIS_PASEP") AS "PIS/PASEP",
    SUM("COFINS") AS "COFINS"
FROM (
SELECT 

    mf."DOC_ENTRY",
    mf."NOTA",
    MF."DATA_DE_LANCAMENTO"  AS "DtLancamento",
    mf."CST",
    FILIAL."BPLId",
    FILIAL."BPLName",
    mf."UTILIZACAO" AS "Usage",
    mf."ID_UTILIZACAO" AS "ID",
    mf."VALOR_MERCADORIA" AS "VL_Mercadoria",
    mf."VALOR_DESCONTOS" AS "VL_Desconto",
    mf."VALOR_TOTAL" AS "Total",
    mf."Base de calculo PIS" AS "Base_de_Calculo",
    mf."PIS_PASEP" AS "PIS_PASEP",
    mf."COFINS" AS "COFINS"
FROM BASE_PIS_COFINS MF
LEFT JOIN OBPL FILIAL ON FILIAL."BPLId" = MF."ID_FILIAL"
)

GROUP BY 
 "BPLId",
 "BPLName",
 "CST",
"DtLancamento";