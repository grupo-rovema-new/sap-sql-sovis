CREATE OR REPLACE VIEW faturamento as

SELECT DISTINCT 
-- HEADER
	T0."DocEntry" ||'-'|| T0."ObjType" AS "PK",
	T0."DocEntry",
	T0."DocNum",
	T0."DiscSum" "Desconto Financeiro",
	COALESCE(T1."Price"*T1."Quantity"*T1."DiscPrcnt"/100,0) "Desconto Produtos",
	T0."Serial" AS "numeroNota",
	T0."CardCode",
	T0."CardName",
	endereco."StateS",
	cidade."Name",
	T0."DocDate" AS "data",
	filial."BPLName" AS filial,
	T0."CANCELED",
	(SELECT SUM("LineTotal") FROM INV13 WHERE "DocEntry" = T0."DocEntry") AS frete,
-- HEADER

-- Produtos
	T1."ItemCode",
	T14."ItemName",
 	T1."LineTotal",
	COALESCE((SELECT SUM(COALESCE(NULLIF("U_TX_VlDeL", 0),"TaxSum")) FROM "INV4" tax WHERE tax."DocEntry" = T1."DocEntry" AND tax."staType" = 25 AND tax."LineNum" = T1."LineNum"),0) AS "desonerado",
	T1."LineTotal"-COALESCE((SELECT SUM(COALESCE(NULLIF("U_TX_VlDeL", 0),"TaxSum")) FROM "INV4" tax WHERE tax."DocEntry" = T1."DocEntry" AND tax."staType" = 25 AND tax."LineNum" = T1."LineNum"),0) AS "faturado",
	T1."Quantity",
	T1."UomCode",
	T1."CFOPCode" CFOP,
	T15."ItmsGrpNam" AS "Grupo de item",
	grupo."BaseQty" AS "Kgs por unidade",
-- Produtos

-- Vendedores
	T4."SlpName",
	T9."U_NomeCompleto" AS "Nome do Representante",
	T12."U_NomeCompleto" AS "Nome do Cordenador",
	CASE
		WHEN T4."SlpName" IN(
			'-Nenhum vendedor-',
			'Alencar',
			'Antonio Santana',
			'Dulce Correia',
			'Erick da Silva',
			'Flavio Garcia',
			'Gustavo Santos',
			'Isadora Tenorio',
			'Larissa Wirla',
			'Leonardo Bosco',
			'Lucas Gomes',
			'Lucas Gomes',
			'Raquel',
			'Tom',
			'Valdecy',
			'Jaqueline Miranda',
			'Adão') 
		THEN 
			'Venda Direta'
		ELSE 'Representante'
	END AS origem
FROM
	"OINV"  T0 
	INNER JOIN "INV1"  T1 ON T0."DocEntry" = T1."DocEntry"
	INNER JOIN "OBPL" filial ON filial."BPLId" = T0."BPLId"
	INNER JOIN "Process" sefaz ON (sefaz."DocType" = T0."ObjType" AND T0."DocEntry" = sefaz."DocEntry")
	LEFT JOIN "INV12"  endereco ON T0."DocEntry" = endereco."DocEntry"
	LEFT JOIN OCNT cidade ON CAST(endereco."CountyS" AS varchar) = CAST(cidade."AbsId" AS varchar)
	LEFT JOIN  "OSLP"  T4 ON T0."SlpCode" = T4."SlpCode"
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
	LEFT JOIN OITB T15 ON T15."ItmsGrpCod" = T14."ItmsGrpCod"
	LEFT JOIN "OUOM" medida ON T1."UomCode" = medida."UomCode"
	LEFT JOIN "UGP1" grupo ON grupo."UgpEntry" = 4 AND grupo."UomEntry" = medida."UomEntry"
WHERE
	sefaz."StatusId" = 4
	AND T0."BPLId" IN(2,4,11,17,18)
	AND T1."CFOPCode" in(5101,5116,5102,6116,6101,6109,5109,6102,6108)

UNION

SELECT DISTINCT 
-- HEADER
	T0."DocEntry" || T0."ObjType" AS "PK",
	T0."DocEntry",
	T0."DocNum",
	-1*T0."DiscSum" "Desconto Financeiro",
	-1*COALESCE(T1."Price"*T1."Quantity"*T1."DiscPrcnt"/100,0) "Desconto Produtos",
	T0."Serial",
	T0."CardCode",
	T0."CardName",
	endereco."StateS",
	cidade."Name",
	T0."DocDate",
	filial."BPLName",
	T0."CANCELED",
	-1*(SELECT SUM("LineTotal") FROM RIN13 WHERE "DocEntry" = T0."DocEntry") AS frete,
-- HEADER

-- Produtos
	T1."ItemCode",
	T14."ItemName",
 	-1*T1."LineTotal",
	COALESCE(-1*(SELECT SUM(COALESCE(NULLIF("U_TX_VlDeL", 0),"TaxSum")) FROM "RIN4" tax WHERE tax."DocEntry" = T1."DocEntry" AND tax."staType" = 25 AND tax."LineNum" = T1."LineNum"),0) AS "desonerado",
	(-1*T1."LineTotal")+COALESCE((SELECT SUM(COALESCE(NULLIF("U_TX_VlDeL", 0),"TaxSum")) FROM "RIN4" tax WHERE tax."DocEntry" = T1."DocEntry" AND tax."staType" = 25 AND tax."LineNum" = T1."LineNum"),0) AS "faturado",
	T1."Quantity",
	T1."UomCode",
	T1."CFOPCode" CFOP,
	T15."ItmsGrpNam" AS "Grupo de item",
	-1*grupo."BaseQty" AS "Kgs por unidade",
-- Produtos

-- Vendedores
	T4."SlpName",
	T9."U_NomeCompleto" AS "Nome do Representante",
	T12."U_NomeCompleto" AS "Nome do Cordenador",
	CASE
		WHEN T4."SlpName" IN(
			'-Nenhum vendedor-',
			'Alencar',
			'Antonio Santana',
			'Dulce Correia',
			'Erick da Silva',
			'Flavio Garcia',
			'Gustavo Santos',
			'Isadora Tenorio',
			'Larissa Wirla',
			'Leonardo Bosco',
			'Lucas Gomes',
			'Lucas Gomes',
			'Raquel',
			'Tom',
			'Valdecy',
			'Jaqueline Miranda',
			'Adão') 
		THEN 
			'Venda Direta'
		ELSE 'Representante'
	END AS origem
FROM
	"ORIN"  T0 
	INNER JOIN "RIN1"  T1 ON T0."DocEntry" = T1."DocEntry"
	INNER JOIN "OBPL" filial ON filial."BPLId" = T0."BPLId"
	INNER JOIN "Process" sefaz ON (sefaz."DocType" = T0."ObjType" AND T0."DocEntry" = sefaz."DocEntry")
	LEFT JOIN "RIN12"  endereco ON T0."DocEntry" = endereco."DocEntry"
	LEFT JOIN OCNT cidade ON CAST(endereco."CountyS" AS varchar) = CAST(cidade."AbsId" AS varchar)
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
	sefaz."StatusId" = 4
	AND T0."BPLId" IN(2,4,11,17,18)
	AND T1."CFOPCode" in(1201,1202,2201)
	
	
UNION


SELECT DISTINCT 
-- HEADER
	T0."DocEntry" || T0."ObjType" AS "PK",
	T0."DocEntry",
	T0."DocNum",
	T0."DiscSum" "Desconto Financeiro",
	COALESCE(T1."Price"*T1."Quantity"*T1."DiscPrcnt"/100,0) "Desconto Produtos",
	T0."Serial",
	T0."CardCode",
	T0."CardName",
	endereco."StateS",
	cidade."Name",
	T0."DocDate",
	filial."BPLName",
	T0."CANCELED",
	(SELECT SUM("LineTotal") FROM DLN13 WHERE "DocEntry" = T0."DocEntry") AS frete,
-- HEADER
	
-- Produtos
	T1."ItemCode",
	T14."ItemName",
 	T1."LineTotal",
	COALESCE((SELECT SUM(COALESCE(NULLIF("U_TX_VlDeL", 0),"TaxSum")) FROM "DLN4" tax WHERE tax."DocEntry" = T1."DocEntry" AND tax."staType" in(25,28) AND tax."LineNum" = T1."LineNum"),0) AS "desonerado",
	T1."LineTotal"-COALESCE((SELECT SUM(COALESCE(NULLIF("U_TX_VlDeL", 0),"TaxSum")) FROM "DLN4" tax WHERE tax."DocEntry" = T1."DocEntry" AND tax."staType" in(25,28) AND tax."LineNum" = T1."LineNum"),0) AS "faturado",
	T1."Quantity",
	T1."UomCode",
	T1."CFOPCode" CFOP,
	T15."ItmsGrpNam" AS "Grupo de item",
	grupo."BaseQty" AS "Kgs por unidade",
-- Produtos

-- Vendedores
	T4."SlpName",
	T9."U_NomeCompleto" AS "Nome do Representante",
	T12."U_NomeCompleto" AS "Nome do Cordenador",
	CASE
		WHEN T4."SlpName" IN(
			'-Nenhum vendedor-',
			'Alencar',
			'Antonio Santana',
			'Dulce Correia',
			'Erick da Silva',
			'Flavio Garcia',
			'Gustavo Santos',
			'Isadora Tenorio',
			'Larissa Wirla',
			'Leonardo Bosco',
			'Lucas Gomes',
			'Lucas Gomes',
			'Raquel',
			'Tom',
			'Valdecy',
			'Jaqueline Miranda',
			'Adão') 
		THEN 
			'Venda Direta'
		ELSE 'Representante'
	END AS origem
FROM
	"ODLN"  T0 
	INNER JOIN "DLN1"  T1 ON T0."DocEntry" = T1."DocEntry"
	INNER JOIN "OBPL" filial ON filial."BPLId" = T0."BPLId"
	INNER JOIN "Process" sefaz ON (sefaz."DocType" = T0."ObjType" AND T0."DocEntry" = sefaz."DocEntry")
	LEFT JOIN "DLN12"  endereco ON T0."DocEntry" = endereco."DocEntry"
	LEFT JOIN OCNT cidade ON CAST(endereco."CountyS" AS varchar) = CAST(cidade."AbsId" AS varchar)
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
	sefaz."StatusId" = 4
	AND T0."BPLId" IN(2,4,11,17,18)
	AND T1."CFOPCode" in(5101,5116,5102,6116,6101,6109,5109,6102,6108)


UNION 


SELECT DISTINCT 
-- HEADER
	T0."DocEntry" || T0."ObjType" AS "PK",
	T0."DocEntry",
	T0."DocNum",
	-1*T0."DiscSum" "Desconto Financeiro",
	-1*COALESCE(T1."Price"*T1."Quantity"*T1."DiscPrcnt"/100,0) "Desconto Produtos",
	T0."Serial",
	T0."CardCode",
	T0."CardName",
	endereco."StateS",
	cidade."Name",
	T0."DocDate",
	filial."BPLName",
	T0."CANCELED",
	(SELECT SUM("LineTotal") FROM RDN13 WHERE "DocEntry" = T0."DocEntry") AS frete,
-- HEADER
	
-- Produtos
	T1."ItemCode",
	T14."ItemName",
 	-1*T1."LineTotal",
	COALESCE(-1*(SELECT SUM(COALESCE(NULLIF("U_TX_VlDeL", 0),"TaxSum")) FROM "RDN4" tax WHERE tax."DocEntry" = T1."DocEntry" AND tax."staType" in(25,28) AND tax."LineNum" = T1."LineNum"),0) AS "desonerado",
	(-1*T1."LineTotal")+COALESCE((SELECT SUM(COALESCE(NULLIF("U_TX_VlDeL", 0),"TaxSum")) FROM "RDN4" tax WHERE tax."DocEntry" = T1."DocEntry" AND tax."staType" in(25,28) AND tax."LineNum" = T1."LineNum"),0) AS "faturado",
	T1."Quantity",
	T1."UomCode",
	T1."CFOPCode" CFOP,
	T15."ItmsGrpNam" AS "Grupo de item",
	-1*grupo."BaseQty" AS "Kgs por unidade",
-- Produtos

-- Vendedores
	T4."SlpName",
	T9."U_NomeCompleto" AS "Nome do Representante",
	T12."U_NomeCompleto" AS "Nome do Cordenador",
	CASE
		WHEN T4."SlpName" IN(
			'-Nenhum vendedor-',
			'Alencar',
			'Antonio Santana',
			'Dulce Correia',
			'Erick da Silva',
			'Flavio Garcia',
			'Gustavo Santos',
			'Isadora Tenorio',
			'Larissa Wirla',
			'Leonardo Bosco',
			'Lucas Gomes',
			'Lucas Gomes',
			'Raquel',
			'Tom',
			'Valdecy',
			'Jaqueline Miranda',
			'Adão') 
		THEN 
			'Venda Direta'
		ELSE 'Representante'
	END AS origem
FROM
	"ORDN"  T0 
	INNER JOIN "RDN1"  T1 ON T0."DocEntry" = T1."DocEntry"
	INNER JOIN "OBPL" filial ON filial."BPLId" = T0."BPLId"
	INNER JOIN "Process" sefaz ON (sefaz."DocType" = T0."ObjType" AND T0."DocEntry" = sefaz."DocEntry")
	LEFT JOIN "RDN12"  endereco ON T0."DocEntry" = endereco."DocEntry"
	LEFT JOIN OCNT cidade ON CAST(endereco."CountyS" AS varchar) = CAST(cidade."AbsId" AS varchar)
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
	sefaz."StatusId" = 4
	AND T0."BPLId" IN(2,4,11,17,18)
	AND T1."CFOPCode" in(1201,1202,2201)

	
	
