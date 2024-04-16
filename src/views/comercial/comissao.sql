CREATE OR REPLACE VIEW RELATORIOCOMISSAO AS
SELECT * FROM 
(
SELECT 
T0."CardCode",
T0."DocEntry",
T0."CardName" AS "Cliente",
T2."DocNum" AS "Nº Pagamento#",
T2."DocEntry",
T5."Price",
T0."Serial" AS "Nº Nota",
T1."InstId",
T0."Installmnt" as "Nº Parcelas",
T0."DocDate" AS "Data de lançamento",
T0."DocTotal" AS "Total Nota",
T2."DocDate" AS "Data de Pagamento",
CASE 
	WHEN	T1."PaidSum" = 0  THEN T1."AppliedSys"
	ELSE T1."PaidSum" 
END AS "Total pago",
--T3."InstlmntID" AS "Parcela",
--T3."DueDate" AS "Data de Vencimento" ,
T0."BPLId",
T0."BPLName",
T0."SlpCode",
T4."SlpName" AS "Vendedor",
T5."DiscPrcnt" AS "Desconto",
T5."U_preco_base",
T5."ItemCode" as "CodProduto",
T5."Dscription" as "Produto",
T5."U_ROV_PREBASE",
T5."U_preco_negociado",
T0."isIns",
CASE
	WHEN T0."isIns" = 'Y' THEN 
	COALESCE((SELECT SUM(COALESCE("U_TX_VlDeL", 0)) FROM "INV4" tax WHERE tax."DocEntry" = T5."DocEntry" AND (tax."staType" = 28 OR tax."staType" = 10)AND tax."LineNum" = T5."LineNum"),0) 
	ELSE COALESCE((SELECT SUM(COALESCE("U_TX_VlDeL", 0)) FROM "INV4" tax WHERE tax."DocEntry" = T5."DocEntry" AND tax."staType" = 25 AND tax."LineNum" = T5."LineNum"),0) 
END AS "desonerado",
CASE 
	WHEN T0."isIns" = 'Y' THEN  
	T5."LineTotal"-COALESCE((SELECT SUM(COALESCE("U_TX_VlDeL", 0)) FROM "INV4" tax WHERE tax."DocEntry" = T5."DocEntry" AND ( tax."staType" = 28 OR tax."staType" = 10) AND tax."LineNum" = T5."LineNum"),0) 
	ELSE T5."LineTotal"-COALESCE((SELECT SUM(COALESCE("U_TX_VlDeL", 0)) FROM "INV4" tax WHERE tax."DocEntry" = T5."DocEntry" AND  tax."staType" = 25 AND tax."LineNum" = T5."LineNum"),0) 
END AS "faturado",
T5."Quantity",
T7."PymntGroup",
T11."U_regressiva",
T11."U_porcentagem",
T10."ListName",
COALESCE(T8."LineTotal",0) as "Frete"


FROM "OINV" T0
 INNER JOIN "INV6" T3 ON T3."DocEntry" = T0."DocEntry" 
INNER JOIN "RCT2" T1 ON T1."DocEntry" = T0."DocEntry" AND
T1."DocTransId" = T0."TransId" AND T1."InstId" = T3."InstlmntID" 
 INNER JOIN "ORCT" T2 ON T2."DocEntry" = T1."DocNum" AND T2."Canceled" = 'N'
 INNER JOIN "OSLP" T4 ON T0."SlpCode" = T4."SlpCode"
 INNER JOIN "INV1" T5 ON T0."DocEntry" = T5."DocEntry"
 INNER JOIN "OCTG" T7 ON T0."GroupNum" =T7."GroupNum"
 LEFT JOIN  "RIN21" T6 ON T0."DocNum" = T6."RefDocNum" AND T6."RefDocNum" IS NULL 
 LEFT JOIN  "ORIN" T12 ON T6."DocEntry" = T12."DocEntry" AND T12."CANCELED" = 'N'
 LEFT JOIN  "INV21" T9 ON T0."DocNum" = T9."RefDocNum"
 LEFT JOIN "INV3" T8 ON T0."DocEntry" = T8."DocEntry"
 LEFT JOIN "OPLN" T10 ON T5."U_idTabela" = T10."ListNum"
 LEFT JOIN "@COMISSAO" T11 ON T10."U_tipoComissao" = T11."Code"

 WHERE 
T0."CANCELED" = 'N' 
AND (T5."Usage" = 9 or T5."Usage" = 16)
AND T0."DocDate" >= TO_DATE(20230701,'YYYYMMDD')
--AND T9."RefDocNum" IS NULL
AND T0."U_Rov_Refaturamento" = 'NAO'
 
 UNION 
 
 SELECT 
T0."CardCode",
T0."DocEntry",
T0."CardName" AS "Cliente",
T2."DocNum" AS "Nº Pagamento#",
T2."DocEntry",
T5."Price",
T0."Serial" AS "Nº Nota",
T1."InstId",
T0."Installmnt" as "Nº Parcelas",
T0."DocDate" AS "Data de lançamento",
T12."DrawnSum" AS "Total Nota",
T2."DocDate" AS "Data de Pagamento",
CASE 
	WHEN	T1."PaidSum" = 0  THEN T1."AppliedSys"
	ELSE T1."PaidSum" 
END AS "Total pago",
--T3."InstlmntID" AS "Parcela",
--T3."DueDate" AS "Data de Vencimento" ,
T0."BPLId",
T0."BPLName",
T0."SlpCode",
T4."SlpName" AS "Vendedor",
T5."DiscPrcnt" AS "Desconto",
T5."U_preco_base",
T5."ItemCode" as "CodProduto",
T5."Dscription" as "Produto",
T5."U_ROV_PREBASE",
T5."U_preco_negociado",
T0."isIns",
CASE
	WHEN T0."isIns" = 'Y' THEN 
	COALESCE((SELECT SUM(COALESCE("U_TX_VlDeL", 0)) FROM "INV4" tax WHERE tax."DocEntry" = T5."DocEntry" AND (tax."staType" = 28 OR tax."staType" = 10)AND tax."LineNum" = T5."LineNum"),0) 
	ELSE COALESCE((SELECT SUM(COALESCE("U_TX_VlDeL", 0)) FROM "INV4" tax WHERE tax."DocEntry" = T5."DocEntry" AND tax."staType" = 25 AND tax."LineNum" = T5."LineNum"),0) 
END AS "desonerado",
CASE 
	WHEN T0."isIns" = 'Y' THEN  
	T5."LineTotal"-COALESCE((SELECT SUM(COALESCE("U_TX_VlDeL", 0)) FROM "INV4" tax WHERE tax."DocEntry" = T5."DocEntry" AND ( tax."staType" = 28 OR tax."staType" = 10) AND tax."LineNum" = T5."LineNum"),0) 
	ELSE T5."LineTotal"-COALESCE((SELECT SUM(COALESCE("U_TX_VlDeL", 0)) FROM "INV4" tax WHERE tax."DocEntry" = T5."DocEntry" AND  tax."staType" = 25 AND tax."LineNum" = T5."LineNum"),0) 
END AS "faturado",

T5."Quantity",
T7."PymntGroup",
T11."U_regressiva",
T11."U_porcentagem",
T10."ListName",
COALESCE(T8."LineTotal",0) as "Frete"


FROM "OINV" T0
 INNER JOIN "INV6" T3 ON T3."DocEntry" = T0."DocEntry" 
 INNER JOIN "INV9" T12 ON T0."DocEntry" = T12."DocEntry" 
 INNER JOIN "RCT2" T1 ON T12."DocEntry" = T1."DocEntry" AND T1."InvType"  = 203
 INNER  JOIN "ORCT" T2 ON T2."DocEntry" = T1."DocNum"
AND T2."Canceled" = 'N'
 INNER JOIN "OSLP" T4 ON T0."SlpCode" = T4."SlpCode"
 INNER JOIN "INV1" T5 ON T0."DocEntry" = T5."DocEntry"
 INNER JOIN "OCTG" T7 ON T0."GroupNum" =T7."GroupNum"
 LEFT JOIN  "RIN21" T6 ON T0."DocNum" = T6."RefDocNum" AND T6."RefDocNum" IS NULL 
 LEFT JOIN  "ORIN" T13 ON T6."DocEntry" = T13."DocEntry" AND T13."CANCELED" = 'N'
 LEFT JOIN  "INV21" T9 ON T0."DocNum" = T9."RefDocNum"
 LEFT JOIN "INV3" T8 ON T0."DocEntry" = T8."DocEntry"
 LEFT JOIN "OPLN" T10 ON T5."U_idTabela" = T10."ListNum"
 LEFT JOIN "@COMISSAO" T11 ON T10."U_tipoComissao" = T11."Code"
 WHERE T0."CANCELED" = 'N' AND
(T5."Usage" = 9 or T5."Usage" = 16)
AND T0."DocDate" >= TO_DATE(20230701,'YYYYMMDD')
--AND T9."RefDocNum" IS NULL
AND T0."U_Rov_Refaturamento" = 'NAO'
 )
WHERE
"Data de Pagamento" >= '20240401'
AND "Data de Pagamento" <= '20240410'


--SELECT * FROM OINV WHERE "isIns" = 'Y' ORDER BY "DocNum" desc

--SELECT "U_TX_VlDeL", "TaxSum", "staType",*  FROM inv4 WHERE "DocEntry" = 38084 AND "LineNum" = 0

