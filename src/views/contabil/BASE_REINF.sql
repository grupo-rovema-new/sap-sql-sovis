CREATE OR REPLACE VIEW BASE_REINF AS
(WITH "BASE_PCH" AS (SELECT 
        L."DocEntry",
        ROUND(SUM(L."Quantity" * L."PriceBefDi"), 4) AS "BASE_DE_CALCULO",
        MAX(L."CSTfPIS")  AS "CST",
        MAX(L."TaxCode")  AS "CODIGO_IMPOSTO",
        MAX(L."CFOPCode") AS "CFOP"
    FROM PCH1 L
    GROUP BY L."DocEntry"), "IMPOSTOS_PCH" AS (SELECT
        IR."AbsEntry" AS "DocEntry",
        SUM(CASE WHEN IRT."WTTypeId" = 1  THEN IR."WTAmntSC" ELSE 0 END) AS "PIS",
        SUM(CASE WHEN IRT."WTTypeId" = 2  THEN IR."WTAmntSC" ELSE 0 END) AS "COFINS",
        SUM(CASE WHEN IRT."WTTypeId" = 4  THEN IR."WTAmntSC" ELSE 0 END) AS "CSLL",
        SUM(CASE WHEN IRT."WTTypeId" = 3  THEN IR."WTAmntSC" ELSE 0 END) AS "IRRF",
        SUM(CASE WHEN IRT."WTTypeId" = 5  THEN IR."WTAmntSC" ELSE 0 END) AS "INSS",
        SUM(CASE WHEN IRT."WTTypeId" = 13 THEN IR."WTAmntSC" ELSE 0 END) AS "SENAR",
        SUM(CASE WHEN IRT."WTTypeId" = 18 THEN IR."WTAmntSC" ELSE 0 END) AS "GILRAT",
        SUM(IR."WTAmntSC") AS "TOTAL_IMPOSTOS"
    FROM PCH5 IR
    LEFT JOIN OWHT IRT ON IR."WTCode" = IRT."WTCode"
    GROUP BY IR."AbsEntry"), "BASE_PDN" AS (SELECT 
        L."DocEntry",
        ROUND(SUM(L."Quantity" * L."PriceBefDi"), 4) AS "BASE_DE_CALCULO",
        MAX(L."CSTfPIS")  AS "CST",
        MAX(L."TaxCode")  AS "CODIGO_IMPOSTO",
        MAX(L."CFOPCode") AS "CFOP"
    FROM PDN1 L
    GROUP BY L."DocEntry"), "IMPOSTOS_PDN" AS (SELECT
        IR."AbsEntry" AS "DocEntry",
        SUM(CASE WHEN IRT."WTTypeId" = 1  THEN IR."WTAmntSC" ELSE 0 END) AS "PIS",
        SUM(CASE WHEN IRT."WTTypeId" = 2  THEN IR."WTAmntSC" ELSE 0 END) AS "COFINS",
        SUM(CASE WHEN IRT."WTTypeId" = 4  THEN IR."WTAmntSC" ELSE 0 END) AS "CSLL",
        SUM(CASE WHEN IRT."WTTypeId" = 3  THEN IR."WTAmntSC" ELSE 0 END) AS "IRRF",
        SUM(CASE WHEN IRT."WTTypeId" = 5  THEN IR."WTAmntSC" ELSE 0 END) AS "INSS",
        SUM(CASE WHEN IRT."WTTypeId" = 13 THEN IR."WTAmntSC" ELSE 0 END) AS "SENAR",
        SUM(CASE WHEN IRT."WTTypeId" = 18 THEN IR."WTAmntSC" ELSE 0 END) AS "GILRAT",
        SUM(IR."WTAmntSC") AS "TOTAL_IMPOSTOS"
    FROM PDN5 IR
    LEFT JOIN OWHT IRT ON IR."WTCode" = IRT."WTCode"
    GROUP BY IR."AbsEntry"), "BASE_INV" AS (SELECT 
        L."DocEntry",
        ROUND(SUM(L."Quantity" * L."PriceBefDi"), 4) AS "BASE_DE_CALCULO",
        MAX(L."CSTfPIS")  AS "CST",
        MAX(L."TaxCode")  AS "CODIGO_IMPOSTO",
        MAX(L."CFOPCode") AS "CFOP"
    FROM INV1 L
    GROUP BY L."DocEntry"), "IMPOSTOS_INV" AS (SELECT
        IR."DocEntry" AS "DocEntry",
        SUM(CASE WHEN IR."staType" IN (33,34,35) THEN IR."TaxSum" ELSE 0 END) AS "FUNRURAL"
    FROM INV4 IR
    GROUP BY IR."DocEntry") (SELECT
    'ENTRADA' AS "TIPO",
    N."DocDate"  AS "DATA_DE_LANCAMENTO",
    N."TaxDate"  AS "DATA_DOC",
    N."ObjType"  AS "OBJ_TYPE",
    N."DocEntry" AS "DOC_ENTRY",
    N."DocNum"   AS "NUMERO_DOC",
    N."Serial"   AS "NOTA",
    N."BPLId"    AS "ID_FILIAL",
    N."BPLName"  AS "Filial",
    N."CardCode" AS "CODIGO_PARCEIRO",
    N."CardName" AS "NOME_PARCEIRO",
    COALESCE(CF."TaxId0", CF."TaxId4") AS "CPF_CNPJ",
    CF."TaxId1" AS "INSCRICAO_ESTADUAL",
    A."Descr"   AS "TIPO_PESSOA",
    B."CST",
    B."CODIGO_IMPOSTO",
    B."CFOP",
    COALESCE(B."BASE_DE_CALCULO", 0) AS "BASE_DE_CALCULO",
    COALESCE(T."PIS",0)    AS "PIS",
    COALESCE(T."COFINS",0) AS "COFINS",
    COALESCE(T."CSLL",0)   AS "CSLL",
    COALESCE(T."IRRF",0)   AS "IRRF",
    COALESCE(T."INSS",0)   AS "INSS",
    COALESCE(T."SENAR",0)  AS "SENAR",
    COALESCE(T."GILRAT",0) AS "GILRAT",
    (COALESCE(T."INSS",0) + COALESCE(T."SENAR",0) + COALESCE(T."GILRAT",0)) AS "FUNRURAL",
    COALESCE(T."PIS",0)+COALESCE(T."COFINS",0)+COALESCE(T."CSLL",0) AS "CSRF",
    COALESCE(T."TOTAL_IMPOSTOS", 0) AS "TOTAL_IMPOSTOS"
FROM OPCH N
LEFT JOIN base_pch     B ON B."DocEntry" = N."DocEntry"
LEFT JOIN impostos_pch T ON T."DocEntry" = N."DocEntry"
LEFT JOIN CRD7         CF ON CF."CardCode" = N."CardCode" AND CF."Address" = ''
LEFT JOIN CRD11        TP ON TP."CardCode" = N."CardCode"
LEFT JOIN OBNI         A ON A."Code" = TP."TributType" AND A."IndexType" = 18
WHERE N."CANCELED" = 'N') UNION ALL (SELECT
    'SAIDA' AS "TIPO",
    N."DocDate"  AS "DATA_DE_LANCAMENTO",
    N."TaxDate"  AS "DATA_DOC",
    N."ObjType"  AS "OBJ_TYPE",
    N."DocEntry" AS "DOC_ENTRY",
    N."DocNum"   AS "NUMERO_DOC",
    N."Serial"   AS "NOTA",
    N."BPLId"    AS "ID_FILIAL",
    N."BPLName"  AS "Filial",
    N."CardCode" AS "CODIGO_PARCEIRO",
    N."CardName" AS "NOME_PARCEIRO",
    COALESCE(CF."TaxId0", CF."TaxId4") AS "CPF_CNPJ",
    CF."TaxId1" AS "INSCRICAO_ESTADUAL",
    A."Descr"   AS "TIPO_PESSOA",
    B."CST",
    B."CODIGO_IMPOSTO",
    B."CFOP",
    COALESCE(B."BASE_DE_CALCULO", 0) AS "BASE_DE_CALCULO",
    0 AS "PIS",
    0 AS "COFINS",
    0 AS "CSLL",
    0 AS "IRRF",
    0 AS "INSS",
    0 AS "SENAR",
    0 AS "GILRAT",
    COALESCE(T."FUNRURAL",0) AS "FUNRURAL",
    0 AS "CSRF",
    COALESCE(T."FUNRURAL",0) AS "TOTAL_IMPOSTOS"
FROM OINV N
LEFT JOIN base_inv     B ON B."DocEntry" = N."DocEntry"
LEFT JOIN impostos_inv T ON T."DocEntry" = N."DocEntry"
LEFT JOIN CRD7         CF ON CF."CardCode" = N."CardCode" AND CF."Address" = ''
LEFT JOIN CRD11        TP ON TP."CardCode" = N."CardCode"
LEFT JOIN OBNI         A ON A."Code" = TP."TributType" AND A."IndexType" = 18
WHERE N."CANCELED" = 'N'));