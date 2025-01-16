

CREATE OR REPLACE VIEW BASE_PIS_COFINS AS
SELECT
	"TIPO" ,
	"DATA_DE_LANCAMENTO" ,
	"OBJ_TYPE" ,
	"DOC_ENTRY" ,
	"NUMERO_DOC" ,
	"NOTA" ,
	"ID_FILIAL" ,
	"CODIGO_PARCEIRO" ,
	"NOME_PARCEIRO" ,
	"NUMERO_LINHA" ,
	"CODIGO_ITEM" ,
	"DESCRICAO_ITEM" ,
	"QUANTIDADE" ,
	"PRECO_UNITARIO" ,
	"ID_UTILIZACAO" ,
	"UTILIZACAO" ,
	"CST" ,
	"CODIGO_IMPOSTO" ,
	"CFOP" ,
	"Alicota ICMS" ,
	"Base de calculo ICMS" ,
	"ICMS" ,
	"Alicota IPI" ,
	"Base de calculo IPI" ,
	"IPI" ,
	"Alicota ISS" ,
	"Base de calculo ISS" ,
	"ISS" ,
	"Alicota PIS" ,
	"Base de calculo PIS" ,
	"PIS_PASEP" ,
	"Alicota COFINS" ,
	"Base de calculo COFINS" ,
	"COFINS" ,
	"DESCONTO_LINHA" ,
	"VALOR_MERCADORIA" ,
	"VALOR_DESCONTOS" ,
	"VALOR_TOTAL"
FROM
	(
	SELECT
		'ENTRADA' AS "TIPO",
		N."DocDate" AS "DATA_DE_LANCAMENTO",
		N."ObjType" AS "OBJ_TYPE",
		N."DocEntry" AS "DOC_ENTRY",
		N."DocNum" AS "NUMERO_DOC",
		N."Serial" AS "NOTA",
		N."BPLId" AS "ID_FILIAL",
		N."CardCode" AS "CODIGO_PARCEIRO",
		N."CardName" AS "NOME_PARCEIRO",
		L."LineNum" AS "NUMERO_LINHA",
		L."ItemCode" AS "CODIGO_ITEM",
		L."Dscription" AS "DESCRICAO_ITEM",
		ROUND(L."Quantity", 4) AS "QUANTIDADE",
		ROUND(L."PriceBefDi", 4) AS "PRECO_UNITARIO",
		COALESCE(O."ID",0) AS "ID_UTILIZACAO",
		COALESCE(O."Usage",'SEM UTILIZAÇÃO') AS "UTILIZACAO",
		L."CSTfPIS" AS "CST",
		L."TaxCode" AS "CODIGO_IMPOSTO",
		L."CFOPCode" AS "CFOP",
		ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" = 10 AND O."ID" NOT IN (16,54)  AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota ICMS",

ROUND(
    COALESCE(
        SUM(
            CASE 
	            WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo ICMS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (10) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" = 10 AND O."ID" NOT IN (16,54)  AND I."TaxStatus" = 'Y'  THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS ICMS,

ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota IPI",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo IPI",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (16) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS IPI,

ROUND(
    COALESCE(
        MAX(
            CASE 
	            WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota ISS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo ISS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS ISS,

ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota PIS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo PIS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "PIS_PASEP",

ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota COFINS",

ROUND(
    COALESCE(
        SUM(
            CASE 
	            WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo COFINS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS COFINS,
		ROUND(L."PriceBefDi" * (L."DiscPrcnt" / 100), 2) AS DESCONTO_LINHA,
		ROUND(COALESCE(L."Quantity" * L."PriceBefDi", 0), 2) AS "VALOR_MERCADORIA",
		ROUND(COALESCE(N."DiscSum", 0), 2) AS "VALOR_DESCONTOS",
		ROUND(COALESCE(N."DocTotal", 0), 2) AS "VALOR_TOTAL"
	FROM
		OPCH N
	LEFT JOIN PCH1 L ON
		N."DocEntry" = L."DocEntry"
	LEFT JOIN OUSG O ON
		L."Usage" = O."ID"
	LEFT JOIN PCH4 I ON
		L."DocEntry" = I."DocEntry"
		AND L."LineNum" = I."LineNum"
	WHERE
		N."CANCELED" = 'N'
	GROUP BY
		N."DocDate",
		N."DocEntry",
		N."DocNum",
		N."Serial",
		N."BPLId",
		N."CardCode",
		L."Quantity",
		L."PriceBefDi",
		N."CardName",
		L."LineNum",
		L."ItemCode",
		L."Dscription",
		O."ID",
		O."Usage",
		L."CSTfPIS",
		L."TaxCode",
		L."CFOPCode",
		L."DiscPrcnt",
		COALESCE(L."Quantity" * L."PriceBefDi",
		0),
		COALESCE(N."DiscSum",
		0),
		COALESCE(N."DocTotal",
		0),
		N."ObjType"
UNION ALL
	SELECT
		'SAIDA' AS "TIPO",
		N."DocDate" AS "DATA_DE_LANCAMENTO",
		N."ObjType" AS "OBJ_TYPE",
		N."DocEntry" AS "DOC_ENTRY",
		N."DocNum" AS "NUMERO_DOC",
		N."Serial" AS "NOTA",
		N."BPLId" AS "ID_FILIAL",
		N."CardCode" AS "CODIGO_PARCEIRO",
		N."CardName" AS "NOME_PARCEIRO",
		L."LineNum" AS "NUMERO_LINHA",
		L."ItemCode" AS "CODIGO_ITEM",
		L."Dscription" AS "DESCRICAO_ITEM",
		ROUND(L."Quantity", 4) AS "QUANTIDADE",
		ROUND(L."PriceBefDi", 4) AS "PRECO_UNITARIO",
		COALESCE(O."ID",0) AS "ID_UTILIZACAO",
		COALESCE(O."Usage",'SEM UTILIZAÇÃO') AS "UTILIZACAO",
		L."CSTfPIS" AS "CST",
		L."TaxCode" AS "CODIGO_IMPOSTO",
		L."CFOPCode" AS "CFOP",
	ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota ICMS",

ROUND(
    COALESCE(
        SUM(
            CASE 
	            WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo ICMS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (10) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" = 10 AND O."ID" NOT IN (16,54)  AND I."TaxStatus" = 'Y'  THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS ICMS,

ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota IPI",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo IPI",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (16) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS IPI,

ROUND(
    COALESCE(
        MAX(
            CASE 
	            WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota ISS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo ISS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS ISS,

ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota PIS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo PIS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "PIS_PASEP",

ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota COFINS",

ROUND(
    COALESCE(
        SUM(
            CASE 
	            WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo COFINS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS COFINS,
		ROUND(L."PriceBefDi" * (L."DiscPrcnt" / 100), 2) AS DESCONTO_LINHA,
		ROUND(COALESCE(L."Quantity" * L."PriceBefDi", 0), 2) AS "VALOR_MERCADORIA",
		ROUND(COALESCE(N."DiscSum", 0), 2) AS "VALOR_DESCONTOS",
		ROUND(COALESCE(N."DocTotal", 0), 2) AS "VALOR_TOTAL"
	FROM
		OINV N
	LEFT JOIN INV1 L ON
		N."DocEntry" = L."DocEntry"
	LEFT JOIN OUSG O ON
		L."Usage" = O."ID"
	LEFT JOIN INV4 I ON
		L."DocEntry" = I."DocEntry"
		AND L."LineNum" = I."LineNum"
	WHERE
		N."CANCELED" = 'N'
	GROUP BY
		N."DocDate",
		N."DocEntry",
		N."DocNum",
		N."Serial",
		N."BPLId",
		N."CardCode",
		L."Quantity",
		L."PriceBefDi",
		N."CardName",
		L."LineNum",
		L."ItemCode",
		L."Dscription",
		O."ID",
		O."Usage",
		L."CSTfPIS",
		L."TaxCode",
		L."CFOPCode",
		L."DiscPrcnt",
		COALESCE(L."Quantity" * L."PriceBefDi",
		0),
		COALESCE(N."DiscSum",
		0),
		COALESCE(N."DocTotal",
		0),
		N."ObjType"
UNION ALL
	SELECT
		'SAIDA' AS "TIPO",
		N."DocDate" AS "DATA_DE_LANCAMENTO",
		N."ObjType" AS "OBJ_TYPE",
		N."DocEntry" AS "DOC_ENTRY",
		N."DocNum" AS "NUMERO_DOC",
		N."Serial" AS "NOTA",
		N."BPLId" AS "ID_FILIAL",
		N."CardCode" AS "CODIGO_PARCEIRO",
		N."CardName" AS "NOME_PARCEIRO",
		L."LineNum" AS "NUMERO_LINHA",
		L."ItemCode" AS "CODIGO_ITEM",
		L."Dscription" AS "DESCRICAO_ITEM",
		ROUND(L."Quantity", 4) AS "QUANTIDADE",
		ROUND(L."PriceBefDi", 4) AS "PRECO_UNITARIO",
		COALESCE(O."ID",0) AS "ID_UTILIZACAO",
		COALESCE(O."Usage",'SEM UTILIZAÇÃO') AS "UTILIZACAO",
		L."CSTfPIS" AS "CST",
		L."TaxCode" AS "CODIGO_IMPOSTO",
		L."CFOPCode" AS "CFOP",
	ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota ICMS",

ROUND(
    COALESCE(
        SUM(
            CASE 
	            WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo ICMS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (10) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" = 10 AND O."ID" NOT IN (16,54)  AND I."TaxStatus" = 'Y'  THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS ICMS,

ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota IPI",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo IPI",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (16) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS IPI,

ROUND(
    COALESCE(
        MAX(
            CASE 
	            WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota ISS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo ISS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS ISS,

ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota PIS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo PIS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "PIS_PASEP",

ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota COFINS",

ROUND(
    COALESCE(
        SUM(
            CASE 
	            WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo COFINS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS COFINS,
		ROUND(L."PriceBefDi" * (L."DiscPrcnt" / 100), 2) AS DESCONTO_LINHA,
		ROUND(COALESCE(L."Quantity" * L."PriceBefDi", 0), 2) AS "VALOR_MERCADORIA",
		ROUND(COALESCE(N."DiscSum", 0), 2) AS "VALOR_DESCONTOS",
		ROUND(COALESCE(N."DocTotal", 0), 2) AS "VALOR_TOTAL"
	FROM
		ODLN N
	LEFT JOIN DLN1 L ON
		N."DocEntry" = L."DocEntry"
	LEFT JOIN OUSG O ON
		L."Usage" = O."ID"
	LEFT JOIN DLN4 I ON
		L."DocEntry" = I."DocEntry"
		AND L."LineNum" = I."LineNum"
	WHERE
		N."CANCELED" = 'N'
	GROUP BY
		N."DocDate",
		N."DocEntry",
		N."DocNum",
		N."Serial",
		N."BPLId",
		N."CardCode",
		L."Quantity",
		L."PriceBefDi",
		N."CardName",
		L."LineNum",
		L."ItemCode",
		L."Dscription",
		O."ID",
		O."Usage",
		L."CSTfPIS",
		L."TaxCode",
		L."CFOPCode",
		L."DiscPrcnt",
		COALESCE(L."Quantity" * L."PriceBefDi",
		0),
		COALESCE(N."DiscSum",
		0),
		COALESCE(N."DocTotal",
		0),
		N."ObjType"
UNION ALL
	SELECT
		'SAIDA' AS "TIPO",
		N."DocDate" AS "DATA_DE_LANCAMENTO",
		N."ObjType" AS "OBJ_TYPE",
		N."DocEntry" AS "DOC_ENTRY",
		N."DocNum" AS "NUMERO_DOC",
		N."Serial" AS "NOTA",
		N."BPLId" AS "ID_FILIAL",
		N."CardCode" AS "CODIGO_PARCEIRO",
		N."CardName" AS "NOME_PARCEIRO",
		L."LineNum" AS "NUMERO_LINHA",
		L."ItemCode" AS "CODIGO_ITEM",
		L."Dscription" AS "DESCRICAO_ITEM",
		ROUND(L."Quantity", 4) AS "QUANTIDADE",
		ROUND(L."PriceBefDi", 4) AS "PRECO_UNITARIO",
		COALESCE(O."ID",0) AS "ID_UTILIZACAO",
		COALESCE(O."Usage",'SEM UTILIZAÇÃO') AS "UTILIZACAO",
		L."CSTfPIS" AS "CST",
		L."TaxCode" AS "CODIGO_IMPOSTO",
		L."CFOPCode" AS "CFOP",
	ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota ICMS",

ROUND(
    COALESCE(
        SUM(
            CASE 
	            WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo ICMS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (10) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" = 10 AND O."ID" NOT IN (16,54)  AND I."TaxStatus" = 'Y'  THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS ICMS,

ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota IPI",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo IPI",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (16) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS IPI,

ROUND(
    COALESCE(
        MAX(
            CASE 
	            WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota ISS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo ISS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS ISS,

ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota PIS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo PIS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "PIS_PASEP",

ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota COFINS",

ROUND(
    COALESCE(
        SUM(
            CASE 
	            WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo COFINS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS COFINS,
		ROUND(L."PriceBefDi" * (L."DiscPrcnt" / 100), 2) AS DESCONTO_LINHA,
		ROUND(COALESCE(L."Quantity" * L."PriceBefDi", 0), 2) AS "VALOR_MERCADORIA",
		ROUND(COALESCE(N."DiscSum", 0), 2) AS "VALOR_DESCONTOS",
		ROUND(COALESCE(N."DocTotal", 0), 2) AS "VALOR_TOTAL"
	FROM
		ORPC N
	LEFT JOIN RPC1 L ON
		N."DocEntry" = L."DocEntry"
	LEFT JOIN OUSG O ON
		L."Usage" = O."ID"
	LEFT JOIN RPC4 I ON
		L."DocEntry" = I."DocEntry"
		AND L."LineNum" = I."LineNum"
	WHERE
		N."CANCELED" = 'N'
	GROUP BY
		N."DocDate",
		N."DocEntry",
		N."DocNum",
		N."Serial",
		N."BPLId",
		N."CardCode",
		L."Quantity",
		L."PriceBefDi",
		N."CardName",
		L."LineNum",
		L."ItemCode",
		L."Dscription",
		O."ID",
		O."Usage",
		L."CSTfPIS",
		L."TaxCode",
		L."CFOPCode",
		L."DiscPrcnt",
		COALESCE(L."Quantity" * L."PriceBefDi",
		0),
		COALESCE(N."DiscSum",
		0),
		COALESCE(N."DocTotal",
		0),
		N."ObjType"
UNION ALL
	SELECT
		'ENTRADA' AS "TIPO",
		N."DocDate" AS "DATA_DE_LANCAMENTO",
		N."ObjType" AS "OBJ_TYPE",
		N."DocEntry" AS "DOC_ENTRY",
		N."DocNum" AS "NUMERO_DOC",
		N."Serial" AS "NOTA",
		N."BPLId" AS "ID_FILIAL",
		N."CardCode" AS "CODIGO_PARCEIRO",
		N."CardName" AS "NOME_PARCEIRO",
		L."LineNum" AS "NUMERO_LINHA",
		L."ItemCode" AS "CODIGO_ITEM",
		L."Dscription" AS "DESCRICAO_ITEM",
		ROUND(L."Quantity", 4) AS "QUANTIDADE",
		ROUND(L."PriceBefDi", 4) AS "PRECO_UNITARIO",
		COALESCE(O."ID",0) AS "ID_UTILIZACAO",
		COALESCE(O."Usage",'SEM UTILIZAÇÃO') AS "UTILIZACAO",
		L."CSTfPIS" AS "CST",
		L."TaxCode" AS "CODIGO_IMPOSTO",
		L."CFOPCode" AS "CFOP",
	ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota ICMS",

ROUND(
    COALESCE(
        SUM(
            CASE 
	            WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo ICMS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (10) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" = 10 AND O."ID" NOT IN (16,54)  AND I."TaxStatus" = 'Y'  THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS ICMS,

ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota IPI",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo IPI",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (16) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS IPI,

ROUND(
    COALESCE(
        MAX(
            CASE 
	            WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota ISS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo ISS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS ISS,

ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota PIS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo PIS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "PIS_PASEP",

ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota COFINS",

ROUND(
    COALESCE(
        SUM(
            CASE 
	            WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo COFINS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS COFINS,
		ROUND(L."PriceBefDi" * (L."DiscPrcnt" / 100), 2) AS DESCONTO_LINHA,
		ROUND(COALESCE(L."Quantity" * L."PriceBefDi", 0), 2) AS "VALOR_MERCADORIA",
		ROUND(COALESCE(N."DiscSum", 0), 2) AS "VALOR_DESCONTOS",
		ROUND(COALESCE(N."DocTotal", 0), 2) AS "VALOR_TOTAL"
	FROM
		ORDN N
	LEFT JOIN RDN1 L ON
		N."DocEntry" = L."DocEntry"
	LEFT JOIN OUSG O ON
		L."Usage" = O."ID"
	LEFT JOIN RDN4 I ON
		L."DocEntry" = I."DocEntry"
		AND L."LineNum" = I."LineNum"
	WHERE
		N."CANCELED" = 'N'
	GROUP BY
		N."DocDate",
		N."DocEntry",
		N."DocNum",
		N."Serial",
		N."BPLId",
		N."CardCode",
		L."Quantity",
		L."PriceBefDi",
		N."CardName",
		L."LineNum",
		L."ItemCode",
		L."Dscription",
		O."ID",
		O."Usage",
		L."CSTfPIS",
		L."TaxCode",
		L."CFOPCode",
		L."DiscPrcnt",
		COALESCE(L."Quantity" * L."PriceBefDi",
		0),
		COALESCE(N."DiscSum",
		0),
		COALESCE(N."DocTotal",
		0),
		N."ObjType"
UNION ALL
	SELECT
		'ENTRADA' AS "TIPO",
		N."DocDate" AS "DATA_DE_LANCAMENTO",
		N."ObjType" AS "OBJ_TYPE",
		N."DocEntry" AS "DOC_ENTRY",
		N."DocNum" AS "NUMERO_DOC",
		N."Serial" AS "NOTA",
		N."BPLId" AS "ID_FILIAL",
		N."CardCode" AS "CODIGO_PARCEIRO",
		N."CardName" AS "NOME_PARCEIRO",
		L."LineNum" AS "NUMERO_LINHA",
		L."ItemCode" AS "CODIGO_ITEM",
		L."Dscription" AS "DESCRICAO_ITEM",
		ROUND(L."Quantity", 4) AS "QUANTIDADE",
		ROUND(L."PriceBefDi", 4) AS "PRECO_UNITARIO",
		COALESCE(O."ID",0) AS "ID_UTILIZACAO",
		COALESCE(O."Usage",'SEM UTILIZAÇÃO') AS "UTILIZACAO",
		L."CSTfPIS" AS "CST",
		L."TaxCode" AS "CODIGO_IMPOSTO",
		L."CFOPCode" AS "CFOP",
		ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota ICMS",

ROUND(
    COALESCE(
        SUM(
            CASE 
	            WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo ICMS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (10) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" = 10 AND O."ID" NOT IN (16,54)  AND I."TaxStatus" = 'Y'  THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS ICMS,

ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota IPI",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo IPI",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (16) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS IPI,

ROUND(
    COALESCE(
        MAX(
            CASE 
	            WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota ISS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo ISS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS ISS,

ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota PIS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo PIS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "PIS_PASEP",

ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota COFINS",

ROUND(
    COALESCE(
        SUM(
            CASE 
	            WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo COFINS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS COFINS,
		ROUND(L."PriceBefDi" * (L."DiscPrcnt" / 100), 2) AS DESCONTO_LINHA,
		ROUND(COALESCE(L."Quantity" * L."PriceBefDi", 0), 2) AS "VALOR_MERCADORIA",
		ROUND(COALESCE(N."DiscSum", 0), 2) AS "VALOR_DESCONTOS",
		ROUND(COALESCE(N."DocTotal", 0), 2) AS "VALOR_TOTAL"
	FROM
		ORIN N
	LEFT JOIN RIN1 L ON
		N."DocEntry" = L."DocEntry"
	LEFT JOIN OUSG O ON
		L."Usage" = O."ID"
	LEFT JOIN RIN4 I ON
		L."DocEntry" = I."DocEntry"
		AND L."LineNum" = I."LineNum"
	WHERE
		N."CANCELED" = 'N'
	GROUP BY
		N."DocDate",
		N."DocEntry",
		N."DocNum",
		N."Serial",
		N."BPLId",
		N."CardCode",
		L."Quantity",
		L."PriceBefDi",
		N."CardName",
		L."LineNum",
		L."ItemCode",
		L."Dscription",
		O."ID",
		O."Usage",
		L."CSTfPIS",
		L."TaxCode",
		L."CFOPCode",
		L."DiscPrcnt",
		COALESCE(L."Quantity" * L."PriceBefDi",
		0),
		COALESCE(N."DiscSum",
		0),
		COALESCE(N."DocTotal",
		0),
		N."ObjType"
UNION ALL
	SELECT
		'SAIDA' AS "TIPO",
		N."DocDate" AS "DATA_DE_LANCAMENTO",
		N."ObjType" AS "OBJ_TYPE",
		N."DocEntry" AS "DOC_ENTRY",
		N."DocNum" AS "NUMERO_DOC",
		N."Serial" AS "NOTA",
		N."BPLId" AS "ID_FILIAL",
		N."CardCode" AS "CODIGO_PARCEIRO",
		N."CardName" AS "NOME_PARCEIRO",
		L."LineNum" AS "NUMERO_LINHA",
		L."ItemCode" AS "CODIGO_ITEM",
		L."Dscription" AS "DESCRICAO_ITEM",
		ROUND(L."Quantity", 4) AS "QUANTIDADE",
		ROUND(L."PriceBefDi", 4) AS "PRECO_UNITARIO",
		COALESCE(O."ID",0) AS "ID_UTILIZACAO",
		COALESCE(O."Usage",'SEM UTILIZAÇÃO') AS "UTILIZACAO",
		L."CSTfPIS" AS "CST",
		L."TaxCode" AS "CODIGO_IMPOSTO",
		L."CFOPCode" AS "CFOP",
	ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota ICMS",

ROUND(
    COALESCE(
        SUM(
            CASE 
	            WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" = 10 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo ICMS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (10) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" = 10 AND O."ID" NOT IN (16,54)  AND I."TaxStatus" = 'Y'  THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS ICMS,

ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota IPI",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo IPI",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (16) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" = 16 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS IPI,

ROUND(
    COALESCE(
        MAX(
            CASE 
	            WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota ISS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo ISS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" = 24 AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS ISS,

ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota PIS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo PIS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" IN (19, 29) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "PIS_PASEP",

ROUND(
    COALESCE(
        MAX(
            CASE
	            WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxRate"
                WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxRate" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Alicota COFINS",

ROUND(
    COALESCE(
        SUM(
            CASE 
	            WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_BaseSum"
                WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "BaseSumSys" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS "Base de calculo COFINS",

ROUND(
    COALESCE(
        SUM(
            CASE
	            WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' AND "U_TX_Adjusted" = 'Y' THEN "U_TX_TaxSum"
                WHEN "staType" IN (21, 30) AND O."ID" NOT IN (16,54) AND I."TaxStatus" = 'Y' THEN "TaxSum" 
                ELSE 0 
            END
        ), 
        0
    ), 
    2
) AS COFINS,
		ROUND(L."PriceBefDi" * (L."DiscPrcnt" / 100), 2) AS DESCONTO_LINHA,
		ROUND(COALESCE(L."Quantity" * L."PriceBefDi", 0), 2) AS "VALOR_MERCADORIA",
		ROUND(COALESCE(N."DiscSum", 0), 2) AS "VALOR_DESCONTOS",
		ROUND(COALESCE(N."DocTotal", 0), 2) AS "VALOR_TOTAL"
	FROM
		ORPD N
	LEFT JOIN RPD1 L ON
		N."DocEntry" = L."DocEntry"
	LEFT JOIN OUSG O ON
		L."Usage" = O."ID"
	LEFT JOIN RPD4 I ON
		L."DocEntry" = I."DocEntry"
		AND L."LineNum" = I."LineNum"
	WHERE
		N."CANCELED" = 'N'
	GROUP BY
		N."DocDate",
		N."DocEntry",
		N."DocNum",
		N."Serial",
		N."BPLId",
		N."CardCode",
		L."Quantity",
		L."PriceBefDi",
		N."CardName",
		L."LineNum",
		L."ItemCode",
		L."Dscription",
		O."ID",
		O."Usage",
		L."CSTfPIS",
		L."TaxCode",
		L."CFOPCode",
		L."DiscPrcnt",
		COALESCE(L."Quantity" * L."PriceBefDi",
		0),
		COALESCE(N."DiscSum",
		0),
		COALESCE(N."DocTotal",
		0),
		N."ObjType"
    ) ORDER BY
	DATA_DE_LANCAMENTO,
	"DOC_ENTRY",
	"NUMERO_LINHA";