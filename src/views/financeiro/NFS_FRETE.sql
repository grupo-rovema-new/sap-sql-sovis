CREATE OR REPLACE VIEW NFS_FRETE AS
SELECT
	--Nota Fiscal de Saída
	T0."DocEntry" AS "EntryNota",
	T0."DocNum" AS "DocNum",
	T2."DocNum" AS "N.Pag",
	T5."BaseLine",
	COALESCE(T8."LineTotal",
	0) AS "FreteGeral", 
	T0."DocTotal",
	FA."faturado",
	T10."DocTotal" AS "Devolução",
	VP."Total pago",
	CT."NumDesdobr",
	T0."Installmnt",
	t5."LineTotal" AS "TotalItem",
	COALESCE(T12."LineTotal",
	0) AS "Frete2",
	COALESCE(T12."LineTotal",
	0) AS "Frete",
	COALESCE(T12."LineTotal",
	0) AS "FreteLinha",
	COALESCE(T12."LineTotal",
	0) * (VP."Total pago" / NULLIF(T0."DocTotal",
	0)) AS "FreteLinha2",
	VP."Total pago"-COALESCE(T12."LineTotal",
	0) AS "PagoSemFrete",
	(round((t5."LineTotal" / NULLIF(NV."TotalBruto",
	0)),
	2))* 100 AS "Percentual",
	(VP."Total pago" / NULLIF(T0."DocTotal",
	0)) AS "Percentual2",
	round(((t5."LineTotal" / NULLIF(NV."TotalBruto",
	0)) * 100)*(T0."DiscPrcnt" / 100),
	2) AS "%DescLinha",
	CASE 
		WHEN CT."NumDesdobr" > T0."Installmnt"
		AND ((round((t5."LineTotal" / NULLIF(NV."TotalBruto",
		0)),
		2))* 100) = 100 THEN (ROUND((t5."LineTotal" / NULLIF(NV."TotalBruto",
		0)),
		2)* VP."Total pago")-COALESCE(T12."LineTotal",
		0) * (VP."Total pago" / NULLIF(T0."DocTotal",
		0))
		WHEN CT."NumDesdobr" > 1
		AND ((round((t5."LineTotal" / NULLIF(NV."TotalBruto",
		0)),
		2))* 100) = 100 THEN (ROUND((t5."LineTotal" / NULLIF(NV."TotalBruto",
		0)),
		2)* VP."Total pago")-COALESCE(T12."LineTotal",
		0) * (VP."Total pago" / NULLIF(T0."DocTotal",
		0))
		WHEN CT."NumDesdobr" > 1
		AND ((round((t5."LineTotal" / NULLIF(NV."TotalBruto",
		0)),
		2))* 100) <> 100 AND T10."DocTotal" IS NULL THEN (ROUND((t5."LineTotal" / NULLIF(NV."TotalBruto",
		0)),
		2)* VP."Total pago")-COALESCE(T12."LineTotal",
		0) * (VP."Total pago" / NULLIF(T0."DocTotal",
		0))
		WHEN CT."NumDesdobr" < T0."Installmnt"
		AND ((round((t5."LineTotal" / NULLIF(NV."TotalBruto",
		0)),
		2))* 100) = 100 THEN (ROUND((t5."LineTotal" / NULLIF(NV."TotalBruto",
		0)),
		2)* VP."Total pago")-COALESCE(T12."LineTotal",
		0) * (VP."Total pago" / NULLIF(T0."DocTotal",
		0))
		WHEN CT."NumDesdobr" > T0."Installmnt"
		AND T10."DocTotal" IS NOT NULL THEN (VP."Total pago"-(COALESCE(T8."LineTotal",
		0)/ CT."NumDesdobr"))*(round((T12."LineTotal" / NULLIF(T8."LineTotal",
		0)),
		2))
		WHEN CT."NumDesdobr" = T0."Installmnt" THEN (ROUND((t5."LineTotal" / NULLIF(NV."TotalBruto",
		0)),
		2)* VP."Total pago")-COALESCE(T12."LineTotal",
		0) * (VP."Total pago" / NULLIF(T0."DocTotal",
		0))
		WHEN (COALESCE(T12."LineTotal",
		0) * (VP."Total pago" / NULLIF(T0."DocTotal",
		0))) < 1 THEN (ROUND((VP."Total pago" / NULLIF(T0."DocTotal",
		0)),
		2)* VP."Total pago")-COALESCE(T12."LineTotal",
		0)
		ELSE (ROUND((VP."Total pago" / NULLIF(T0."DocTotal",
		0)),
		2)* VP."Total pago")-COALESCE(T12."LineTotal",
		0)
	END AS "PagoLiq",
	(ROUND((VP."Total pago" / NULLIF(T0."DocTotal",
	0)),
	2)* VP."Total pago")-COALESCE(T12."LineTotal",
	0) AS "TotPgSFrete",
	(ROUND((t5."LineTotal" / NULLIF(NV."TotalBruto",
	0)),
	2)* VP."Total pago")-COALESCE(T12."LineTotal",
	0) * (VP."Total pago" / NULLIF(T0."DocTotal",
	0)) AS "TotPgSFrete2"
FROM
	OINV T0
INNER JOIN "INV6" T3 ON
		T3."DocEntry" = T0."DocEntry"
INNER JOIN "RCT2" T1 ON
		T1."DocEntry" = T0."DocEntry"
	AND
T1."DocTransId" = T0."TransId"
	AND T1."InstId" = T3."InstlmntID"
INNER JOIN "ORCT" T2 ON
		T2."DocEntry" = T1."DocNum"
	AND T2."Canceled" = 'N'
INNER JOIN "INV1" T5 ON
		T0."DocEntry" = T5."DocEntry"
LEFT JOIN "INV3" T8 ON
		T0."DocEntry" = T8."DocEntry"
LEFT JOIN RIN1 T9 ON
	T0."DocEntry" = T9."BaseEntry"
LEFT JOIN ORIN T10 ON
		T9."DocEntry" = T10."DocEntry"
LEFT JOIN INV13 T12 ON
		T5."DocEntry" = T12."DocEntry"
	AND T5."LineNum" = T12."LineNum"
LEFT JOIN CR_VALORPAGO VP ON 
		T0."DocEntry" = VP."EntryNota"
	AND T2."DocNum" = VP."N.Pag"
	AND T2."DocEntry" = VP."EntryPag"
INNER JOIN "NFS_FATURADO" FA ON
		T0."DocEntry" = FA."EntryNota"
	AND T0."DocNum" = FA."DocNum"
	AND T5."BaseLine" = FA."BaseLine"
LEFT JOIN CR_TITULOSDESDOBRADO ct ON 
		T0."DocEntry" = CT."DocEntry"
	AND T0."DocNum" = CT."DocNum"
LEFT JOIN NFS_VALORBRUTO NV ON
		T0."DocEntry" = NV."DocEntry"
WHERE 
		T0."CANCELED" = 'N'
	AND T0."DocDate" >= TO_DATE(20230701,
	'YYYYMMDD')
	AND T0."U_Rov_Refaturamento" = 'NAO'
UNION

SELECT
	--Fatura Adiantamento de Cliente
	T0."DocEntry" AS "EntryNota",
	T0."DocNum" AS "DocNum",
	T2."DocNum" AS "N.Pag",
	T5."BaseLine",
	COALESCE(T8."LineTotal",
	0) AS "FreteGeral", 
	T14."DocTotal",
	FA."faturado",
	T10."DocTotal" AS "Devolução",
	VP."Total pago",
	CT."NumDesdobr",
	T0."Installmnt",
	t5."LineTotal" AS "TotalItem",
	COALESCE(T12."LineTotal",
	0) AS "Frete2",
	COALESCE(T12."LineTotal",
	0) AS "Frete",
	COALESCE(T12."LineTotal",
	0) AS "FreteLinha",
	COALESCE(T12."LineTotal",
	0) * (VP."Total pago" / NULLIF(T14."DocTotal",
	0)) AS "FreteLinha2",
	VP."Total pago"-COALESCE(T12."LineTotal",
	0) AS "PagoSemFrete",
	(round((t5."LineTotal" / NULLIF(NV."TotalBruto",
	0)),
	2))* 100 AS "Percentual",
	(VP."Total pago" / NULLIF(T14."DocTotal",
	0)) AS "Percentual2",
	round(((t5."LineTotal" / NULLIF(NV."TotalBruto",
	0)) * 100)*(T0."DiscPrcnt" / 100),
	2) AS "%DescLinha",
	CASE 
		WHEN CT."NumDesdobr" > T0."Installmnt" THEN (ROUND((t5."LineTotal" / NULLIF(NV."TotalBruto",
		0)),
		2)* VP."Total pago")-COALESCE(T12."LineTotal",
		0) * (VP."Total pago" / NULLIF(T14."DocTotal",
		0))
		WHEN CT."NumDesdobr" = T0."Installmnt" THEN (ROUND((t5."LineTotal" / NULLIF(NV."TotalBruto",
		0)),
		2)* VP."Total pago")-COALESCE(T12."LineTotal",
		0) * (VP."Total pago" / NULLIF(T14."DocTotal",
		0))
		WHEN (COALESCE(T12."LineTotal",
		0) * (VP."Total pago" / NULLIF(T14."DocTotal",
		0))) < 1 THEN (ROUND((VP."Total pago" / NULLIF(T14."DocTotal",
		0)),
		2)* VP."Total pago")-COALESCE(T12."LineTotal",
		0)
		ELSE (ROUND((VP."Total pago" / NULLIF(T14."DocTotal",
		0)),
		2)* VP."Total pago")-COALESCE(T12."LineTotal",
		0)
	END AS "PagoLiq",
	(ROUND((VP."Total pago" / NULLIF(T14."DocTotal",
	0)),
	2)* VP."Total pago")-COALESCE(T12."LineTotal",
	0) AS "TotPgSFrete",
	(ROUND((t5."LineTotal" / NULLIF(NV."TotalBruto",
	0)),
	2)* VP."Total pago")-COALESCE(T12."LineTotal",
	0) * (VP."Total pago" / NULLIF(T14."DocTotal",
	0)) AS "TotPgSFrete2"
FROM
	OINV T0
INNER JOIN INV9 T13 ON
		T0."DocEntry" = T13."DocEntry"
INNER JOIN ODPI T14 ON
		T13."BaseDocNum" = T14."DocNum"
INNER JOIN "INV6" T3 ON
		T3."DocEntry" = T0."DocEntry"
INNER JOIN "RCT2" T1 ON
		T14."DocEntry" = T1."DocEntry"
	AND T1."InvType" = 203
	AND T1."InstId" = T3."InstlmntID"
LEFT JOIN "ORCT" T2 ON
		T2."DocEntry" = T1."DocNum"
	AND T2."Canceled" = 'N'
LEFT JOIN "INV1" T5 ON
		T0."DocEntry" = T5."DocEntry"
LEFT JOIN "INV3" T8 ON
		T0."DocEntry" = T8."DocEntry"
LEFT JOIN RIN1 T9 ON
	T0."DocEntry" = T9."BaseEntry"
LEFT JOIN ORIN T10 ON
		T9."DocEntry" = T10."DocEntry"
LEFT JOIN INV13 T12 ON
		T5."DocEntry" = T12."DocEntry"
	AND T5."LineNum" = T12."LineNum"
INNER JOIN CR_VALORPAGO VP ON 
		T0."DocEntry" = VP."EntryNota"
	AND T2."DocNum" = VP."N.Pag"
	AND T2."DocEntry" = VP."EntryPag"
LEFT JOIN "NFS_FATURADO" FA ON
		T0."DocEntry" = FA."EntryNota"
	AND T0."DocNum" = FA."DocNum"
	AND T5."BaseLine" = FA."BaseLine"
LEFT JOIN CR_TITULOSDESDOBRADO ct ON 
		T0."DocEntry" = CT."DocEntry"
	AND T0."DocNum" = CT."DocNum"
LEFT JOIN NFS_VALORBRUTO NV ON
		T0."DocEntry" = NV."DocEntry"
WHERE 
		T0."CANCELED" = 'N'
	AND T0."DocDate" >= TO_DATE(20230701,
	'YYYYMMDD')
	AND T0."U_Rov_Refaturamento" = 'NAO'
	AND t5."BaseLine" IS NOT NULL