/*
 * TODO
 * - Remover cartorio
 * - 8216
 * - 7936
 * - 7901
 * 
 * - Matriz recebe os pagamentos das filiais e precisa repassar o valor? Provavelmente sim
 * - Devolucao de transferencias, mercadoria e producao
 * 
 * - 
 * - 
 */

SELECT DISTINCT 
-- HEADER
	T0."DocEntry",
	T0."CardCode",
	T0."CardName",
	T0."DocDate",
	filial."BPLName",
-- HEADER

-- Produtos
	T1."ItemCode",
	T1."Dscription",
 	T1."LineTotal",
	T1."Quantity",
	T1."UomCode",
	T15."ItmsGrpNam" AS "Grupo de item",
	grupo."BaseQty" AS "Kgs por unidade",
-- Produtos

-- Vendedores
	T4."SlpName",
	T9."U_NomeCompleto" AS "Nome do Representante",
	T12."U_NomeCompleto" AS "Nome do Cordenador"
FROM
	"OPCH"  T0 
	INNER JOIN "PCH1"  T1 ON T0."DocEntry" = T1."DocEntry"
	INNER JOIN "OBPL" filial ON filial."BPLId" = T0."BPLId"
	INNER JOIN  "OSLP"  T4 ON T0."SlpCode" = T4."SlpCode"
	INNER JOIN OCTG T7 ON T0."GroupNum" = T7."GroupNum"
	LEFT JOIN PCH3 T6 ON T0."DocEntry" = T6."DocEntry" 
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
	AND T0."DocDate" >= '2023-01-01'
	AND T0."DocDate" <= '2023-12-31'
	AND T0."BPLId" IN(2,4,11,17,18)
	AND T0."CardCode" NOT LIKE 'FLH%'
	AND T0."CardCode" NOT LIKE 'TAX%'
	AND T14."Series" NOT in(93)
	AND T1."Usage" NOT IN(49,110,115,47)

	
UNION

SELECT DISTINCT 
-- HEADER
	T0."DocEntry",
	T0."CardCode",
	T0."CardName",
	T0."DocDate",
	filial."BPLName",
-- HEADER

-- Produtos
	T1."ItemCode",
	T1."Dscription",
 	-1*T1."LineTotal",
	T1."Quantity",
	T1."UomCode",
	T15."ItmsGrpNam" AS "Grupo de item",
	grupo."BaseQty" AS "Kgs por unidade",
-- Produtos

-- Vendedores
	T4."SlpName",
	T9."U_NomeCompleto" AS "Nome do Representante",
	T12."U_NomeCompleto" AS "Nome do Cordenador"
FROM
	"ORPC"  T0 
	INNER JOIN "RPC1"  T1 ON T0."DocEntry" = T1."DocEntry"
	INNER JOIN "OBPL" filial ON filial."BPLId" = T0."BPLId"
	INNER JOIN  "OSLP"  T4 ON T0."SlpCode" = T4."SlpCode"
	INNER JOIN OCTG T7 ON T0."GroupNum" = T7."GroupNum"
	LEFT JOIN RPC3 T6 ON T0."DocEntry" = T6."DocEntry" 
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
	AND T0."DocDate" >= '2023-01-01'
	AND T0."DocDate" <= '2023-12-31'
	AND T0."BPLId" IN(2,4,11,17,18)
	AND T0."CardCode" NOT LIKE 'FLH%'
	AND T0."CardCode" NOT LIKE 'TAX%'
	AND T14."Series" NOT in(93)
	AND T1."Usage" NOT in(49,110,115,47)

	
	

