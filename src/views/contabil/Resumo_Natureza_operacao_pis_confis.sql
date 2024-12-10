CREATE OR REPLACE VIEW RESUMO_NATUREZA_OPERACAO AS 
SELECT 
    "BPLId",
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
DISTINCT 
    mf."DocEntry",
     MF."DocLanc" AS "DtLancamento" ,
    mf."Serial",
    FILIAL."BPLId",
    FILIAL."BPLName",
    UTILIZACAO."Usage",
    UTILIZACAO."ID",
    mf."ValorMercadoria" AS "VL_Mercadoria",
    mf."ValorDesconto" AS "VL_Desconto",
    mf."ValorMercadoria" - mf."ValorDesconto" AS "Total",
    0 AS "Monofasico",
    0 AS "Aliquota_0",
    0 AS "Suspenso",
    0 AS "Nao_incidencia",
    mf."ValorICMS" AS "ICMS",
    mf."ValorIPI" AS "IPI",
    mf."ValorIss" AS "ISS",
    CASE 
    	  WHEN (mf."CstPis" <> 50 AND mf."CstPis" <> 01)  AND UTILIZACAO."ID" NOT IN (17,54)  THEN 0 
    	  ELSE  mf."BasePIS"
    END
    AS "Base_de_Calculo",
    mf."ValorPIS" AS "PIS_PASEP",
    mf."ValorCOFINS" AS "COFINS",
    CASE 
        WHEN MF."ObjType" IN (15, 13, 19, 21) THEN 'SAIDA'
        ELSE 'ENTRADA'
    END AS "TIPO"
FROM "MovFiscal" MF
LEFT JOIN "Entidade" E ON E."ID" = MF."Entidade"
LEFT JOIN OBPL FILIAL ON FILIAL."BPLId" = E."BusinessPlaceId"
LEFT JOIN OUSG UTILIZACAO ON UTILIZACAO.ID = MF."Utilizacao"
WHERE 
  MF."Usuario" <> 222

)
--WHERE "TIPO" = 'SAIDA'
GROUP BY 
"BPLId",
    "BPLName",
    "Usage",
    "ID",
    "TIPO",
   "DtLancamento"
