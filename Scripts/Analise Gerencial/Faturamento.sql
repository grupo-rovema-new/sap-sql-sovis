ALTER VIEW faturamentoAndrew as
SELECT DISTINCT 
-- HEADER
	T0."DocEntry",
	T0."CardCode",
	T0."CardName",
	endereco."StateS",
	cidade."Name",
	T0."DocDate",
	filial."BPLName",
-- HEADER

-- Produtos
	T1."ItemCode",
	T1."Dscription",
 	T1."LineTotal",
	(SELECT sum("TaxSum") FROM "INV4" tax WHERE tax."DocEntry" = T1."DocEntry" AND tax."staType" = 25 AND tax."LineNum" = T1."LineNum") AS "desonerado",
	T1."LineTotal"-COALESCE((SELECT sum("TaxSum") FROM "INV4" tax WHERE tax."DocEntry" = T1."DocEntry" AND tax."staType" = 25 AND tax."LineNum" = T1."LineNum"),1) AS "faturado",
	T1."Quantity",
	T1."UomCode",
	T1."CFOPCode" CFOP,
	T15."ItmsGrpNam" AS "Grupo de item",
	grupo."BaseQty" AS "Kgs por unidade",
-- Produtos

-- Vendedores
	T4."SlpName",
	T9."U_NomeCompleto" AS "Nome do Representante",
	T12."U_NomeCompleto" AS "Nome do Cordenador"
FROM
	"OINV"  T0 
	INNER JOIN "INV1"  T1 ON T0."DocEntry" = T1."DocEntry"
	INNER JOIN "OBPL" filial ON filial."BPLId" = T0."BPLId"
	LEFT JOIN "INV12"  endereco ON T0."DocEntry" = endereco."DocEntry"
	LEFT JOIN OCNT cidade ON endereco."CountyS" = cidade."AbsId"
	INNER JOIN  "OSLP"  T4 ON T0."SlpCode" = T4."SlpCode"
	INNER JOIN OCTG T7 ON T0."GroupNum" = T7."GroupNum"
	LEFT JOIN RIN21 T5 ON T0."DocNum" = T5."RefDocNum"
	LEFT JOIN INV3 T6 ON T0."DocEntry" = T6."DocEntry" 
	INNER JOIN CRD1 T8 ON T0."CardCode" = T8."CardCode" AND T8."AdresType" = 'S'
	LEFT JOIN "@RO_REPRESENTANTE" T9 ON T4."U_CodRepresentante" = T9."Code" 
	LEFT JOIN "@RO_REGIAO_LINHAS" T10 ON T8."U_Localidade" = T10."U_Locais"
	LEFT JOIN "@RO_REGIAO" T11 ON T10."Code" = T11."Code" 
	LEFT JOIN "@RO_CORDENADOR" T12 ON T11."U_CodCordenador" = T12."Code"
	LEFT JOIN "@RO_LOCAIS" T13 ON T13."Code" = T8."U_Localidade"
	INNER JOIN OITM T14 ON T14."ItemCode"  = T1."ItemCode" 
	INNER JOIN OITB T15 ON T15."ItmsGrpCod" = T14."ItmsGrpCod"
	LEFT JOIN "OUOM" medida ON T1."UomCode" = medida."UomCode"
	LEFT JOIN "UGP1" grupo ON grupo."UgpEntry" = 4 AND grupo."UomEntry" = medida."UomEntry"
WHERE
	T0."CANCELED" = 'N'
	AND (T1."Usage"  = 9)
	AND T1."ItemCode" LIKE 'PAC%'
	AND T0."DocDate" >= '2023-01-01'
	AND T0."DocDate" <= '2023-12-31'
	AND T0."BPLId" IN(2,4,11,17,18)

UNION

SELECT DISTINCT 
-- HEADER
	T0."DocEntry",
	T0."CardCode",
	T0."CardName",
	endereco."StateS",
	cidade."Name",
	T0."DocDate",
	filial."BPLName",
-- HEADER

-- Produtos
	T1."ItemCode",
	T1."Dscription",
 	-1*T1."LineTotal",
	-1*(SELECT sum("TaxSum") FROM "RIN4" tax WHERE tax."DocEntry" = T1."DocEntry" AND tax."staType" = 25 AND tax."LineNum" = T1."LineNum") AS "desonerado",
	(-1*T1."LineTotal")+COALESCE((SELECT sum("TaxSum") FROM "RIN4" tax WHERE tax."DocEntry" = T1."DocEntry" AND tax."staType" = 25 AND tax."LineNum" = T1."LineNum"),0) AS "faturado",
	T1."Quantity",
	T1."UomCode",
	T1."CFOPCode" CFOP,
	T15."ItmsGrpNam" AS "Grupo de item",
	-1*grupo."BaseQty" AS "Kgs por unidade",
-- Produtos

-- Vendedores
	T4."SlpName",
	T9."U_NomeCompleto" AS "Nome do Representante",
	T12."U_NomeCompleto" AS "Nome do Cordenador"
FROM
	"ORIN"  T0 
	INNER JOIN "RIN1"  T1 ON T0."DocEntry" = T1."DocEntry"
	INNER JOIN "OBPL" filial ON filial."BPLId" = T0."BPLId"
	LEFT JOIN "RIN12"  endereco ON T0."DocEntry" = endereco."DocEntry"
	LEFT JOIN OCNT cidade ON endereco."CountyS" = cidade."AbsId"
	INNER JOIN  "OSLP"  T4 ON T0."SlpCode" = T4."SlpCode"
	INNER JOIN OCTG T7 ON T0."GroupNum" = T7."GroupNum"
	LEFT JOIN RIN21 T5 ON T0."DocNum" = T5."RefDocNum"
	LEFT JOIN INV3 T6 ON T0."DocEntry" = T6."DocEntry" 
	INNER JOIN CRD1 T8 ON T0."CardCode" = T8."CardCode" AND T8."AdresType" = 'S'
	LEFT JOIN "@RO_REPRESENTANTE" T9 ON T4."U_CodRepresentante" = T9."Code" 
	LEFT JOIN "@RO_REGIAO_LINHAS" T10 ON T8."U_Localidade" = T10."U_Locais"
	LEFT JOIN "@RO_REGIAO" T11 ON T10."Code" = T11."Code" 
	LEFT JOIN "@RO_CORDENADOR" T12 ON T11."U_CodCordenador" = T12."Code"
	LEFT JOIN "@RO_LOCAIS" T13 ON T13."Code" = T8."U_Localidade"
	INNER JOIN OITM T14 ON T14."ItemCode"  = T1."ItemCode" 
	INNER JOIN OITB T15 ON T15."ItmsGrpCod" = T14."ItmsGrpCod"
	LEFT JOIN "OUOM" medida ON T1."UomCode" = medida."UomCode"
	LEFT JOIN "UGP1" grupo ON grupo."UgpEntry" = 4 AND grupo."UomEntry" = medida."UomEntry"
WHERE
	T0."CANCELED" = 'N'
	AND T1."ItemCode" LIKE 'PAC%'
	AND (T1."Usage"  IN(9,39,17))
	AND T0."DocDate" >= '2023-01-01'
	AND T0."DocDate" <= '2023-12-31'
	AND T0."BPLId" IN(2,4,11,17,18)
	
	
UNION


SELECT DISTINCT 
-- HEADER
	T0."DocEntry",
	T0."CardCode",
	T0."CardName",
	endereco."StateS",
	cidade."Name",
	T0."DocDate",
	filial."BPLName",
-- HEADER
-- Produtos
	T1."ItemCode",
	T1."Dscription",
 	T1."LineTotal",
	(SELECT sum(COALESCE(tax."U_TX_VlDeL","TaxSum")) FROM "DLN4" tax WHERE tax."DocEntry" = T1."DocEntry" AND tax."staType" in(25,28) AND tax."LineNum" = T1."LineNum") AS "desonerado",
	T1."LineTotal"-COALESCE((SELECT sum(COALESCE(tax."U_TX_VlDeL","TaxSum")) FROM "DLN4" tax WHERE tax."DocEntry" = T1."DocEntry" AND tax."staType" in(25,28) AND tax."LineNum" = T1."LineNum"),0) AS "faturado",
	T1."Quantity",
	T1."UomCode",
	T1."CFOPCode" CFOP,
	T15."ItmsGrpNam" AS "Grupo de item",
	grupo."BaseQty" AS "Kgs por unidade",
-- Produtos

-- Vendedores
	T4."SlpName",
	T9."U_NomeCompleto" AS "Nome do Representante",
	T12."U_NomeCompleto" AS "Nome do Cordenador"
FROM
	"ODLN"  T0 
	INNER JOIN "DLN1"  T1 ON T0."DocEntry" = T1."DocEntry"
	INNER JOIN "OBPL" filial ON filial."BPLId" = T0."BPLId"
	LEFT JOIN "DLN12"  endereco ON T0."DocEntry" = endereco."DocEntry"
	LEFT JOIN OCNT cidade ON endereco."CountyS" = cidade."AbsId"
	INNER JOIN  "OSLP"  T4 ON T0."SlpCode" = T4."SlpCode"
	INNER JOIN OCTG T7 ON T0."GroupNum" = T7."GroupNum"
	LEFT JOIN DLN21 T5 ON T0."DocNum" = T5."RefDocNum"
	LEFT JOIN INV3 T6 ON T0."DocEntry" = T6."DocEntry" 
	INNER JOIN CRD1 T8 ON T0."CardCode" = T8."CardCode" AND T8."AdresType" = 'S'
	LEFT JOIN "@RO_REPRESENTANTE" T9 ON T4."U_CodRepresentante" = T9."Code" 
	LEFT JOIN "@RO_REGIAO_LINHAS" T10 ON T8."U_Localidade" = T10."U_Locais"
	LEFT JOIN "@RO_REGIAO" T11 ON T10."Code" = T11."Code" 
	LEFT JOIN "@RO_CORDENADOR" T12 ON T11."U_CodCordenador" = T12."Code"
	LEFT JOIN "@RO_LOCAIS" T13 ON T13."Code" = T8."U_Localidade"
	INNER JOIN OITM T14 ON T14."ItemCode"  = T1."ItemCode" 
	INNER JOIN OITB T15 ON T15."ItmsGrpCod" = T14."ItmsGrpCod"
	LEFT JOIN "OUOM" medida ON T1."UomCode" = medida."UomCode"
	LEFT JOIN "UGP1" grupo ON grupo."UgpEntry" = 4 AND grupo."UomEntry" = medida."UomEntry"
WHERE
	T0."CANCELED" = 'N'
	AND T1."ItemCode" LIKE 'PAC%'
	AND (T1."Usage"  in(9,39,17))
	AND T0."DocDate" >= '2023-01-01'
	AND T0."DocDate" <= '2023-12-31'
	AND T0."BPLId" IN(2,4,11,17,18)


UNION 


SELECT DISTINCT 
-- HEADER
	T0."DocEntry",
	T0."CardCode",
	T0."CardName",
	endereco."StateS",
	cidade."Name",
	T0."DocDate",
	filial."BPLName",
-- HEADER
-- Produtos
	T1."ItemCode",
	T1."Dscription",
 	-1*T1."LineTotal",
	-1*(SELECT sum(COALESCE(tax."U_TX_VlDeL","TaxSum")) FROM "RDN4" tax WHERE tax."DocEntry" = T1."DocEntry" AND tax."staType" in(25,28) AND tax."LineNum" = T1."LineNum") AS "desonerado",
	(-1*T1."LineTotal")+COALESCE((SELECT sum(COALESCE(tax."U_TX_VlDeL","TaxSum")) FROM "RDN4" tax WHERE tax."DocEntry" = T1."DocEntry" AND tax."staType" in(25,28) AND tax."LineNum" = T1."LineNum"),0) AS "faturado",
	T1."Quantity",
	T1."UomCode",
	T1."CFOPCode" CFOP,
	T15."ItmsGrpNam" AS "Grupo de item",
	-1*grupo."BaseQty" AS "Kgs por unidade",
-- Produtos

-- Vendedores
	T4."SlpName",
	T9."U_NomeCompleto" AS "Nome do Representante",
	T12."U_NomeCompleto" AS "Nome do Cordenador"
FROM
	"ORDN"  T0 
	INNER JOIN "RDN1"  T1 ON T0."DocEntry" = T1."DocEntry"
	INNER JOIN "OBPL" filial ON filial."BPLId" = T0."BPLId"
	LEFT JOIN "RDN12"  endereco ON T0."DocEntry" = endereco."DocEntry"
	LEFT JOIN OCNT cidade ON endereco."CountyS" = cidade."AbsId"
	INNER JOIN  "OSLP"  T4 ON T0."SlpCode" = T4."SlpCode"
	INNER JOIN OCTG T7 ON T0."GroupNum" = T7."GroupNum"
	LEFT JOIN RDN21 T5 ON T0."DocNum" = T5."RefDocNum"
	LEFT JOIN INV3 T6 ON T0."DocEntry" = T6."DocEntry" 
	INNER JOIN CRD1 T8 ON T0."CardCode" = T8."CardCode" AND T8."AdresType" = 'S'
	LEFT JOIN "@RO_REPRESENTANTE" T9 ON T4."U_CodRepresentante" = T9."Code" 
	LEFT JOIN "@RO_REGIAO_LINHAS" T10 ON T8."U_Localidade" = T10."U_Locais"
	LEFT JOIN "@RO_REGIAO" T11 ON T10."Code" = T11."Code" 
	LEFT JOIN "@RO_CORDENADOR" T12 ON T11."U_CodCordenador" = T12."Code"
	LEFT JOIN "@RO_LOCAIS" T13 ON T13."Code" = T8."U_Localidade"
	INNER JOIN OITM T14 ON T14."ItemCode"  = T1."ItemCode" 
	INNER JOIN OITB T15 ON T15."ItmsGrpCod" = T14."ItmsGrpCod"
	LEFT JOIN "OUOM" medida ON T1."UomCode" = medida."UomCode"
	LEFT JOIN "UGP1" grupo ON grupo."UgpEntry" = 4 AND grupo."UomEntry" = medida."UomEntry"
WHERE
	T0."CANCELED" = 'N'
	AND T1."ItemCode" LIKE 'PAC%'
	AND (T1."Usage"  in(9,39,17))
	AND T0."DocDate" >= '2023-01-01'
	AND T0."DocDate" <= '2023-12-31'
	AND T0."BPLId" IN(2,4,11,17,18)
