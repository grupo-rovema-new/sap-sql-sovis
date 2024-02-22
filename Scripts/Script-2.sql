SELECT DISTINCT 
-- HEADER
	T0."DocEntry" || '-'|| T0."ObjType" AS "PK",
	T0."DocEntry",
	T0."DocNum",
	T0."DiscSum" "Desconto Financeiro",
	COALESCE((T1."GTotal"*T1."DiscPrcnt"/100)-T1."DiscPrcnt"/100*(SELECT SUM(COALESCE(NULLIF("U_TX_VlDeL", 0),"TaxSum")) FROM "INV4" tax WHERE tax."DocEntry" = T1."DocEntry" AND tax."staType" = 25 AND tax."LineNum" = T1."LineNum"),0) "Desconto Produtos",
	T0."Serial",
	T0."CardCode",
	T0."CardName",
	endereco."StateS",
	cidade."Name",
	T0."DocDate",
	filial."BPLName",
	T0."CANCELED",
-- HEADER

-- Produtos
	T1."ItemCode",
	T1."Dscription",
 	T1."LineTotal",
	COALESCE((SELECT SUM(COALESCE(NULLIF("U_TX_VlDeL", 0),"TaxSum")) FROM "INV4" tax WHERE tax."DocEntry" = T1."DocEntry" AND tax."staType" = 25 AND tax."LineNum" = T1."LineNum"),0) AS "desonerado",
	T1."LineTotal"-COALESCE((SELECT SUM(COALESCE(NULLIF("U_TX_VlDeL", 0),"TaxSum")) FROM "INV4" tax WHERE tax."DocEntry" = T1."DocEntry" AND tax."staType" = 25 AND tax."LineNum" = T1."LineNum"),1) AS "faturado",
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
	LEFT JOIN "INV1"  T1 ON T0."DocEntry" = T1."DocEntry"
	LEFT JOIN "OBPL" filial ON filial."BPLId" = T0."BPLId"
	LEFT JOIN "Process" sefaz ON (sefaz."DocType" = T0."ObjType" AND T0."DocEntry" = sefaz."DocEntry")
	LEFT JOIN "INV12"  endereco ON T0."DocEntry" = endereco."DocEntry"
	LEFT JOIN OCNT cidade ON endereco."CountyS" = cidade."AbsId"
	LEFT JOIN  "OSLP"  T4 ON T0."SlpCode" = T4."SlpCode"
	LEFT JOIN OCTG T7 ON T0."GroupNum" = T7."GroupNum"
	LEFT JOIN RIN21 T5 ON T0."DocNum" = T5."RefDocNum"
	LEFT JOIN INV3 T6 ON T0."DocEntry" = T6."DocEntry" 
	LEFT JOIN CRD1 T8 ON T0."CardCode" = T8."CardCode" AND T8."AdresType" = 'S'
	LEFT JOIN "@RO_REPRESENTANTE" T9 ON T4."U_CodRepresentante" = T9."Code" 
	LEFT JOIN "@RO_REGIAO_LINHAS" T10 ON T8."U_Localidade" = T10."U_Locais"
	LEFT JOIN "@RO_REGIAO" T11 ON T10."Code" = T11."Code" 
	LEFT JOIN "@RO_CORDENADOR" T12 ON T11."U_CodCordenador" = T12."Code"
	LEFT JOIN "@RO_LOCAIS" T13 ON T13."Code" = T8."U_Localidade"
	LEFT JOIN OITM T14 ON T14."ItemCode"  = T1."ItemCode" 
	LEFT JOIN OITB T15 ON T15."ItmsGrpCod" = T14."ItmsGrpCod"
	LEFT JOIN "OUOM" medida ON T1."UomCode" = medida."UomCode"
	LEFT JOIN "UGP1" grupo ON grupo."UgpEntry" = 4 AND grupo."UomEntry" = medida."UomEntry"
WHERE
	t0."DocEntry" = 25858
	
	