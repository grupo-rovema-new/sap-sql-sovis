CREATE OR REPLACE VIEW CR_VALORPAGO AS
SELECT --Nota Fiscal de Saída
	T1."PaidSum",
	T1."AppliedSys",
	T0."DocEntry" AS "EntryNota",
	T0."DocNum",
	T2."DocNum" AS "N.Pag",
	T2."DocEntry" AS "EntryPag",
	T0."Serial" AS "NotaFiscal",
	CASE
		WHEN T1."PaidSum" = 0 THEN T1."AppliedSys"
		ELSE T1."PaidSum"
	END AS "Total pago"
FROM
	OINV T0
INNER JOIN "INV6" T3 ON
		T3."DocEntry" = T0."DocEntry"
INNER JOIN "RCT2" T1 ON
		T1."DocEntry" = T0."DocEntry"
	AND T1."DocTransId" = T0."TransId"
	AND T1."InstId" = T3."InstlmntID"
INNER JOIN "ORCT" T2 ON
		T2."DocEntry" = T1."DocNum"
	AND T2."Canceled" = 'N'
WHERE 
	T0."CANCELED" = 'N'
	AND T0."DocDate" >= TO_DATE(20230701, 'YYYYMMDD')
	AND T0."U_Rov_Refaturamento" = 'NAO'
	
UNION 

SELECT --Fatura de Adiantamento de clientes
	DISTINCT 
	T1."PaidSum",
	T1."AppliedSys",
	T0."DocEntry" AS "EntryNota",
	T0."DocNum",
	T2."DocNum" AS "N.Pag",
	T2."DocEntry" AS "EntryPag",
	T0."Serial" AS "NotaFiscal",
	CASE
		WHEN T1."PaidSum" = 0 THEN T1."AppliedSys"
		ELSE T1."PaidSum"
	END AS "Total pago"
FROM
	ODPI T0
INNER JOIN "DPI6" T3 ON
		T3."DocEntry" = T0."DocEntry"
INNER JOIN "RCT2" T1 ON
		T1."DocEntry" = T0."DocEntry"
	AND T1."DocTransId" = T0."TransId"
	AND T1."InstId" = T3."InstlmntID"
INNER JOIN "ORCT" T2 ON
		T2."DocEntry" = T1."DocNum"
	AND T2."Canceled" = 'N'
WHERE 
	T0."CANCELED" = 'N'
	AND T0."DocDate" >= TO_DATE(20230701, 'YYYYMMDD')
	AND T0."U_Rov_Refaturamento" = 'NAO'