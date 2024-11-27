CREATE OR REPLACE VIEW CR_VALORPAGO AS
SELECT
	DISTINCT 
	T0."DocEntry" AS "EntryNota",
	T2."DocNum" AS "N.Pag",
	T2."DocEntry" AS "EntryPag",
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
	AND T0."U_Rov_Refaturamento" = 'NAO';