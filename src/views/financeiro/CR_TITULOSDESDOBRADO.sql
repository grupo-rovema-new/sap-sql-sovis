CREATE OR REPLACE VIEW SBOGRUPOROVEMA.CR_TITULOSDESDOBRADO AS
SELECT
	T0."DocEntry",
	T0."DocNum",
	COUNT(T2."DocNum") AS "NumDesdobr"
FROM
		"OINV" T0
INNER JOIN "INV6" T3 ON
		T3."DocEntry" = T0."DocEntry"
INNER JOIN "RCT2" T1 ON
		T1."DocEntry" = T0."DocEntry"
	AND T1."DocTransId" = T0."TransId"
	AND T1."InstId" = T3."InstlmntID"
INNER JOIN "ORCT" T2 ON
		T2."DocEntry" = T1."DocNum"
	AND T2."Canceled" = 'N'
GROUP BY T0."DocEntry",T0."DocNum"

UNION 

SELECT --Fatura de Adiantamento de clientes
	T0."DocEntry",
	T0."DocNum",
	COUNT(T2."DocNum") AS "NumDesdobr"
FROM
		"ODPI" T0
INNER JOIN "DPI6" T3 ON
		T3."DocEntry" = T0."DocEntry"
INNER JOIN "RCT2" T1 ON
		T1."DocEntry" = T0."DocEntry"
	AND T1."DocTransId" = T0."TransId"
	AND T1."InstId" = T3."InstlmntID"
INNER JOIN "ORCT" T2 ON
		T2."DocEntry" = T1."DocNum"
	AND T2."Canceled" = 'N'
GROUP BY T0."DocEntry",T0."DocNum"