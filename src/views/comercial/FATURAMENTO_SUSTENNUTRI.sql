CREATE OR REPLACE VIEW FATURAMENTO_SUSTENNUTRI AS (
SELECT * FROM
(SELECT
	DISTINCT
    1 AS "CodTipo",
	'Nota Fiscal Saida' AS "Tipo",
	T0."DocEntry",
	t0."DocNum",
	T0."CardCode",
	T0."CardName",
	T0."DocTotal",
	T0."DpmAmnt",
	T0."Serial",
	T0."Comments",
	T1."ItemCode",
	T1."Dscription",
	T1."Quantity",
	T0."DocDate" AS "Data_Nota",
	T3."DocDate" AS "Data_Pedido",
	T1."DiscPrcnt",
	T1."UomCode",
	T9."SalUnitMsr",
	T9."SWeight1",
	T4."SlpCode",
	t1."Usage",
	CASE
		WHEN T0."isIns" = 'Y' THEN COALESCE((SELECT SUM(COALESCE("U_TX_VlDeL", 0)) 
												FROM "INV4" tax 
												WHERE tax."DocEntry" = T5."DocEntry" 
												AND (tax."staType" = 28 OR tax."staType" = 10) 
												AND tax."LineNum" = T5."LineNum"),0)
		ELSE COALESCE((SELECT SUM(COALESCE("U_TX_VlDeL", 0)) 
						FROM "INV4" tax 
						WHERE tax."DocEntry" = T1."DocEntry" 
						AND tax."staType" = 25 
						AND tax."LineNum" = T1."LineNum"),0) 
	END AS "desonerado",
	CASE
		WHEN T0."isIns" = 'Y' THEN T1."LineTotal"-COALESCE((SELECT 
																CASE 
																	WHEN COALESCE(SUM("U_TX_VlDeL"),0) = 0 THEN COALESCE(SUM("TaxSum"),0) 
																	ELSE COALESCE(SUM("U_TX_VlDeL"),0) END 
															FROM "INV4" tax 
																	WHERE tax."DocEntry" = T1."DocEntry" 
																	AND ( tax."staType" = 28 OR tax."staType" = 10)
																	AND tax."LineNum" = T1."LineNum"),0) 
																	ELSE T1."LineTotal"-COALESCE((SELECT 
																									CASE WHEN COALESCE(SUM("U_TX_VlDeL"),0) = 0 THEN COALESCE(SUM("TaxSum"),0) 
																									ELSE COALESCE(SUM("U_TX_VlDeL"),0) END 
																									FROM "INV4" tax 
																									WHERE tax."DocEntry" = T1."DocEntry" 
																									AND tax."staType" = 25 
																									AND tax."LineNum" = T1."LineNum"),0)
	END AS "faturado",
	(SELECT o."Usage" FROM OUSG o WHERE t1."Usage" = o."ID") AS "Utilização",
	T1."Commission",
	T1."CFOPCode", 
	T4."SlpName",
	T0."BPLId" ,
	T0."BPLName",
	COALESCE (T6."LineTotal",
	'0') AS "Frete",
	T7."PymntGroup",
	t0."PeyMethod",
	T7."GroupNum",
	grupo."BaseQty",
	l.IDLINHAPRODUTOERP,
    l.DESCRICAO AS "Linha",
    g.IDGRUPOPRODUTOERP,
    g.DESCRICAO AS "Grupo",
    a.IDCATEGORIAERP,
    a.DESCRICAO AS "Categoria",
	DAYS_BETWEEN(T3."DocDate", T0."DocDate") AS "DiasEntrega",
	T1."Price",
	T1."U_preco_negociado",
	T0."isIns" AS "U_venda_futura",
    t0."U_venda_futura" AS "U_venda_futura2",
    t0."U_LbrAgriNrContrato" AS Contrato,
CASE
    WHEN i."CityS" IS NULL
         OR LENGTH(TRIM(i."CityS")) = 0
    THEN 'SEM CIDADE'
    ELSE UPPER(
        TRIM(
            REPLACE_REGEXPR('[[:space:]]+' IN i."CityS" WITH ' ' OCCURRENCE ALL)
        )
    )
END AS "CidadeNorm"
FROM
	"OINV" T0
INNER JOIN "INV1" T1 ON
	T0."DocEntry" = T1."DocEntry"
INNER JOIN oitm T9 ON
	T1."ItemCode" = T9."ItemCode"
INNER JOIN "OSLP" T4 ON
	T0."SlpCode" = T4."SlpCode"
INNER JOIN OCTG T7 ON
	T0."GroupNum" = T7."GroupNum"
LEFT JOIN RIN21 T5 ON
	T0."DocNum" = T5."RefDocNum"
LEFT JOIN INV13 T6 ON
	T1."DocEntry" = T6."DocEntry"
	AND T1."LineNum" = T6."LineNum"
LEFT JOIN "OUOM" medida ON
	T1."UomCode" = medida."UomCode"
LEFT JOIN "UGP1" grupo ON
	grupo."UgpEntry" = 4
	AND grupo."UomEntry" = medida."UomEntry"
LEFT JOIN "RDR1" T2 ON
	t0."DocEntry" = t2."TrgetEntry"
LEFT JOIN "ORDR" T3 ON
	T2."DocEntry" = T3."DocEntry"
LEFT JOIN INV12 i ON T0."DocEntry" = i."DocEntry"
LEFT JOIN GRUPOPRODUTO g ON T9."U_grupo_sustennutri" = g.IDGRUPOPRODUTOERP
LEFT JOIN LINHAPRODUTO l ON T9."U_linha_sustennutri" = l.IDLINHAPRODUTOERP
LEFT JOIN CATEGORIA a ON T9."U_categoria" = a.IDCATEGORIAERP
WHERE
	T5."RefDocNum" IS NULL
	AND T0."CANCELED" = 'N'
	AND T1."Usage" IN (9,16,129,130)
	AND T0."U_Rov_Refaturamento" = 'NAO'
	AND t0."U_venda_futura" IS NULL
	AND T0."isIns" = 'N'

	
UNION

SELECT
	DISTINCT
    2 AS "CodTipo",
	'NF Entrega Futura' AS "Tipo",
	T0."DocEntry",
	t0."DocNum",
	T0."CardCode",
	T0."CardName",
	T0."DocTotal",
	T0."DpmAmnt",
	T0."Serial",
	T0."Comments",
	T1."ItemCode",
	T1."Dscription",
	T1."Quantity",
	T0."DocDate" AS "Data_Nota",
	T3."DocDate" AS "Data_Pedido",
	T1."DiscPrcnt",
	T1."UomCode",
	T9."SalUnitMsr",
	T9."SWeight1",
	T4."SlpCode",
	t1."Usage",
	CASE
		WHEN T0."isIns" = 'Y' THEN COALESCE((SELECT SUM(COALESCE("U_TX_VlDeL", 0)) 
												FROM "INV4" tax 
												WHERE tax."DocEntry" = T5."DocEntry" 
												AND (tax."staType" = 28 OR tax."staType" = 10) 
												AND tax."LineNum" = T5."LineNum"),0)
		ELSE COALESCE((SELECT SUM(COALESCE("U_TX_VlDeL", 0)) 
						FROM "INV4" tax 
						WHERE tax."DocEntry" = T1."DocEntry" 
						AND tax."staType" = 25 
						AND tax."LineNum" = T1."LineNum"),0) 
	END AS "desonerado",
	CASE
		WHEN T0."isIns" = 'Y' THEN T1."LineTotal"-COALESCE((SELECT 
																CASE 
																	WHEN COALESCE(SUM("U_TX_VlDeL"),0) = 0 THEN COALESCE(SUM("TaxSum"),0) 
																	ELSE COALESCE(SUM("U_TX_VlDeL"),0) END 
															FROM "INV4" tax 
																	WHERE tax."DocEntry" = T1."DocEntry" 
																	AND ( tax."staType" = 28 OR tax."staType" = 10)
																	AND tax."LineNum" = T1."LineNum"),0) 
																	ELSE T1."LineTotal"-COALESCE((SELECT 
																									CASE WHEN COALESCE(SUM("U_TX_VlDeL"),0) = 0 THEN COALESCE(SUM("TaxSum"),0) 
																									ELSE COALESCE(SUM("U_TX_VlDeL"),0) END 
																									FROM "INV4" tax 
																									WHERE tax."DocEntry" = T1."DocEntry" 
																									AND tax."staType" = 25 
																									AND tax."LineNum" = T1."LineNum"),0)
	END AS "faturado",
	(SELECT o."Usage" FROM OUSG o WHERE t1."Usage" = o."ID") AS "Utilização",
	T1."Commission",
	T1."CFOPCode", 
	T4."SlpName",
	T0."BPLId" ,
    T0."BPLName",
	COALESCE (T6."LineTotal",
	'0') AS "Frete",
	T7."PymntGroup",
	t0."PeyMethod",
	T7."GroupNum",
	grupo."BaseQty",
	l.IDLINHAPRODUTOERP,
    l.DESCRICAO AS "Linha",
    g.IDGRUPOPRODUTOERP,
    g.DESCRICAO AS "Grupo",
    a.IDCATEGORIAERP,
    a.DESCRICAO AS "Categoria",
	DAYS_BETWEEN(T3."DocDate", T0."DocDate") AS "DiasEntrega",
	T1."Price",
	T1."U_preco_negociado",
	T0."isIns" AS "U_venda_futura",
    t0."U_venda_futura" AS "U_venda_futura2",
    t0."U_LbrAgriNrContrato" AS Contrato,
CASE
    WHEN i."CityS" IS NULL
         OR LENGTH(TRIM(i."CityS")) = 0
    THEN 'SEM CIDADE'
    ELSE UPPER(
        TRIM(
            REPLACE_REGEXPR('[[:space:]]+' IN i."CityS" WITH ' ' OCCURRENCE ALL)
        )
    )
END AS "CidadeNorm"
FROM
	"OINV" T0
INNER JOIN "INV1" T1 ON
	T0."DocEntry" = T1."DocEntry"
INNER JOIN oitm T9 ON
	T1."ItemCode" = T9."ItemCode"
INNER JOIN "OSLP" T4 ON
	T0."SlpCode" = T4."SlpCode"
INNER JOIN OCTG T7 ON
	T0."GroupNum" = T7."GroupNum"
LEFT JOIN RIN21 T5 ON
	T0."DocNum" = T5."RefDocNum"
LEFT JOIN INV13 T6 ON
	T1."DocEntry" = T6."DocEntry"
	AND T1."LineNum" = T6."LineNum"
LEFT JOIN "OUOM" medida ON
	T1."UomCode" = medida."UomCode"
LEFT JOIN "UGP1" grupo ON
	grupo."UgpEntry" = 4
	AND grupo."UomEntry" = medida."UomEntry"
LEFT JOIN "RDR1" T2 ON
	t0."DocEntry" = t2."TrgetEntry"
LEFT JOIN "ORDR" T3 ON
	T2."DocEntry" = T3."DocEntry"
LEFT JOIN INV12 i ON T0."DocEntry" = i."DocEntry"
LEFT JOIN GRUPOPRODUTO g ON T9."U_grupo_sustennutri" = g.IDGRUPOPRODUTOERP
LEFT JOIN LINHAPRODUTO l ON T9."U_linha_sustennutri" = l.IDLINHAPRODUTOERP
LEFT JOIN CATEGORIA a ON T9."U_categoria" = a.IDCATEGORIAERP
WHERE
	T5."RefDocNum" IS NULL
	AND T0."CANCELED" = 'N'
	AND T1."Usage" IN (9,16,129,130)
	AND T0."U_Rov_Refaturamento" = 'NAO'
	AND t0."U_venda_futura" IS NULL
	AND T0."isIns" = 'Y'

	
UNION

SELECT
	3 AS "CodTipo",
	'Contrato Venda Futura' AS "Tipo",
	T0."DocEntry",
	t0."DocNum",
	T0."CardCode",
	T0."CardName",
	T0."DocTotal",
	T0."DpmAmnt",
	T0."Serial",
	T0."Comments",
	T1."ItemCode",
	T1."Dscription",
	T1."Quantity",
	T0."DocDate" AS "Data_Nota",
	T0."DocDate" AS "Data_Pedido",
	T1."DiscPrcnt",
	T1."UomCode",
	T9."SalUnitMsr",
	T9."SWeight1",
	T4."SlpCode",
	t1."Usage",
	CASE
		WHEN T0."isIns" = 'Y' THEN COALESCE((SELECT SUM(COALESCE("U_TX_VlDeL", 0)) 
												FROM "INV4" tax 
												WHERE tax."DocEntry" = T5."DocEntry" 
												AND (tax."staType" = 28 OR tax."staType" = 10) 
												AND tax."LineNum" = T5."LineNum"),0)
		ELSE COALESCE((SELECT SUM(COALESCE("U_TX_VlDeL", 0)) 
						FROM "INV4" tax 
						WHERE tax."DocEntry" = T1."DocEntry" 
						AND tax."staType" = 25 
						AND tax."LineNum" = T1."LineNum"),0) 
	END AS "desonerado",
	CASE
		WHEN T0."isIns" = 'Y' THEN T1."LineTotal"-COALESCE((SELECT 
																CASE 
																	WHEN COALESCE(SUM("U_TX_VlDeL"),0) = 0 THEN COALESCE(SUM("TaxSum"),0) 
																	ELSE COALESCE(SUM("U_TX_VlDeL"),0) END 
															FROM "INV4" tax 
																	WHERE tax."DocEntry" = T1."DocEntry" 
																	AND ( tax."staType" = 28 OR tax."staType" = 10)
																	AND tax."LineNum" = T1."LineNum"),0) 
																	ELSE T1."LineTotal"-COALESCE((SELECT 
																									CASE WHEN COALESCE(SUM("U_TX_VlDeL"),0) = 0 THEN COALESCE(SUM("TaxSum"),0) 
																									ELSE COALESCE(SUM("U_TX_VlDeL"),0) END 
																									FROM "INV4" tax 
																									WHERE tax."DocEntry" = T1."DocEntry" 
																									AND tax."staType" = 25 
																									AND tax."LineNum" = T1."LineNum"),0)
	END AS "faturado",
	(SELECT o."Usage" FROM OUSG o WHERE t1."Usage" = o."ID") AS "Utilização",
	T1."Commission",
	T1."CFOPCode", 
	T4."SlpName",
	T0."BPLId" ,
	T0."BPLName",
	COALESCE (T6."LineTotal",
	'0') AS "Frete",
	T7."PymntGroup",
	t0."PeyMethod",
	T7."GroupNum",
	grupo."BaseQty",
	l.IDLINHAPRODUTOERP,
    l.DESCRICAO AS "Linha",
    g.IDGRUPOPRODUTOERP,
    g.DESCRICAO AS "Grupo",
    a.IDCATEGORIAERP,
    a.DESCRICAO AS "Categoria",
	DAYS_BETWEEN(T0."DocDate", T0."DocDate") AS "DiasEntrega",
	T1."Price",
	T1."U_preco_negociado",
	T0."isIns" AS "U_venda_futura",
    ACF."DocNum" AS "U_venda_futura2",
    t0."U_LbrAgriNrContrato" AS Contrato,
	CASE
    WHEN i."CityS" IS NULL
         OR LENGTH(TRIM(i."CityS")) = 0
    THEN 'SEM CIDADE'
    ELSE UPPER(
        TRIM(
            REPLACE_REGEXPR('[[:space:]]+' IN i."CityS" WITH ' ' OCCURRENCE ALL)
        )
    )
END AS "CidadeNorm"
FROM
	ORDR T0
LEFT JOIN RDR1 T1 ON
	T0."DocEntry" = T1."DocEntry"
INNER JOIN "OSLP" T4 ON	
	T0."SlpCode" = T4."SlpCode"
LEFT JOIN RIN21 T5 ON
	T0."DocNum" = T5."RefDocNum"
LEFT JOIN RDR13 T6 ON
	T1."DocEntry" = T6."DocEntry"
	AND T1."LineNum" = T6."LineNum"
INNER JOIN OCTG T7 ON
	T0."GroupNum" = T7."GroupNum"
INNER JOIN oitm T9 ON
	T1."ItemCode" = T9."ItemCode"
LEFT JOIN "OUOM" medida ON
	T1."UomCode" = medida."UomCode"
LEFT JOIN "UGP1" grupo ON
	grupo."UgpEntry" = 4
	AND grupo."UomEntry" = medida."UomEntry"
LEFT JOIN "@AR_CONTRATO_FUTURO" acf ON
	T0."DocEntry" = ACF."U_orderDocEntry"
LEFT JOIN RDR12 i ON T0."DocEntry" = i."DocEntry"
LEFT JOIN GRUPOPRODUTO g ON T9."U_grupo_sustennutri" = g.IDGRUPOPRODUTOERP
LEFT JOIN LINHAPRODUTO l ON T9."U_linha_sustennutri" = l.IDLINHAPRODUTOERP
LEFT JOIN CATEGORIA a ON T9."U_categoria" = a.IDCATEGORIAERP
WHERE
	T5."RefDocNum" IS NULL
	AND T0."CANCELED" = 'N'
	AND T1."Usage" IN (9,16,129,130)
	AND T0."U_Rov_Refaturamento" = 'NAO'
	AND ACF."U_status" = 'aberto') ORDER BY "DocEntry"
)