CREATE OR REPLACE VIEW NFS_FRETE AS
SELECT
	T0."DocEntry" AS "EntryNota",
	T0."DocNum" AS "DocNum",
	T2."DocNum" AS "N.Pag",
	T5."BaseLine",
	COALESCE(T8."LineTotal",0) AS "Frete", 
	T0."DocTotal",
	FA."faturado",
	VP."Total pago",
	t5."LineTotal" AS "TotalItem",
	COALESCE(T12."LineTotal",0) AS "Frete",
	VP."Total pago"-COALESCE(T12."LineTotal",0) AS "PagoSemFrete",
	(round((t5."LineTotal" / NULLIF(NV."TotalBruto",0)),2))*100 AS "Percentual",
	round(((t5."LineTotal" / NULLIF(NV."TotalBruto",0)) * 100)*(T0."DiscPrcnt"/100),2) AS "%DescLinha",
	(ROUND((t5."LineTotal" / NULLIF(NV."TotalBruto",0)),2)*VP."Total pago")-COALESCE(T12."LineTotal",0) AS "TotPgSFrete"
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
LEFT JOIN NFS_VALORBRUTO NV ON
		T0."DocEntry" = NV."DocEntry"
WHERE 
		T0."CANCELED" = 'N'
	AND T0."DocDate" >= TO_DATE(20230701, 'YYYYMMDD')
	AND T0."U_Rov_Refaturamento" = 'NAO'
	ORDER by t0."DocEntry" ;