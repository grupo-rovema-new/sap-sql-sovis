CREATE OR REPLACE VIEW NFS_FRETE AS
SELECT
	'Nota Fiscal de Saída' AS "Tipo",
	CV."EntryNota",
	O."DocNum", 
	T5."BaseLine",
	cv."N.Pag",
	cv."EntryPag",
	cv."DocLine",
	o."Installmnt" AS "Prestação",
	nn."N.Itens",
	cv."Total pago",
	cv."Total pago"*(t5."LineTotal" / NULLIF(NV."TotalBruto",0)) AS "TotalPago2",
	o."DocTotal",
	t5."LineTotal",
	COALESCE(T8."LineTotal",0) AS "FreteGeral",
	COALESCE(i."LineTotal",0) AS "Frete",
	COALESCE(i."LineTotal",0) / o."Installmnt" AS "FretePorParcela",
	COALESCE(i."LineTotal",0) * (cv."Total pago" / NULLIF(o."DocTotal",0)) AS "FreteLinha",
	COALESCE(T8."LineTotal",0)*(cv."Total pago" / NULLIF(o."DocTotal",0)) AS "FreteLinha2",
	cv."Total pago" - COALESCE(i."LineTotal",0) AS "PagoSemFrete",
	(t5."LineTotal" / NULLIF(NV."TotalBruto",0)) AS "Percentual",
	(cv."Total pago" / NULLIF(o."DocTotal",0)) AS "Percentual2",
	round(((t5."LineTotal" / NULLIF(NV."TotalBruto",0)) * 100)*(o."DiscPrcnt" / 100),2) AS "%DescLinha",
	(ROUND((CV."Total pago" / NULLIF(O."DocTotal",	0)),2)* CV."Total pago")-COALESCE(I."LineTotal",0) AS "TotPgSFrete",
	((t5."LineTotal" / NULLIF(NV."TotalBruto",0))* CV."Total pago")-COALESCE(I."LineTotal",0) * (CV."Total pago" / NULLIF(O."DocTotal",0)) AS "TotPgSFrete2",
	(ROUND((t5."LineTotal" / NULLIF(NV."TotalBruto",0)),2)* CV."Total pago")-COALESCE(T8."LineTotal",0)*(cv."Total pago" / NULLIF(o."DocTotal",0)) AS "TotPgSFrete3",
	(cv."Total pago" * (t5."LineTotal" / NULLIF(NV."TotalBruto",0))) - COALESCE(i."LineTotal",0) / o."Installmnt" AS "TotPgSFrete4",
	(cv."Total pago" * (t5."LineTotal" / NULLIF(NV."TotalBruto",0))) - (COALESCE(T8."LineTotal",0)/ct."NumDesdobr")*(t5."LineTotal" / NULLIF(NV."TotalBruto",0)) AS "TotPgSFrete5",
	cv."Total pago" - (COALESCE(i."LineTotal",0) / o."Installmnt") AS "TotPgSFrete6"
FROM
	CR_VALORPAGO cv
LEFT JOIN NFS_FRETELINHA i ON 
	CV."EntryNota" = I."DocEntry"
LEFT JOIN OINV o ON 
	CV."EntryNota" = O."DocEntry"
LEFT JOIN "INV1" T5 ON
	i."DocEntry" = T5."DocEntry" AND I."LineNum" = t5."LineNum"
LEFT JOIN NFS_VALORBRUTO NV ON
	CV."EntryNota" = NV."DocEntry"
LEFT JOIN "INV3" T8 ON
	o."DocEntry" = T8."DocEntry"
inner JOIN NFS_NUMITENSNOTA NN ON 
	o."DocEntry" = NN."DocEntry"
LEFT JOIN CR_TITULOSDESDOBRADO ct ON 
	o."DocEntry" = ct."DocEntry"
WHERE
	o."CANCELED" = 'N'
	AND o."DocDate" >= TO_DATE(20230701,'YYYYMMDD')
	AND o."U_Rov_Refaturamento" = 'NAO'
	AND o."DpmAmnt" = 0 --QUANDO É UMA NOTA FISCAL DE SAIDA NORMAL
	AND o."isIns" = 'N' 
	
	UNION 
	
	SELECT 
	'Nota Fiscal Entrega Futura' AS "Tipo",
	CV."EntryNota",
	O."DocNum", 
	i."LineNum" AS "BaseLine",
	cv."N.Pag",
	cv."EntryPag",
	cv."DocLine",
	o."Installmnt" AS "Prestação",
	nn."N.Itens",
	cv."Total pago",
	cv."Total pago"*(t5."LineTotal" / NULLIF(NV."TotalBruto",0)) AS "TotalPago2",
	o."DocTotal",
	t5."LineTotal",
	COALESCE(T8."LineTotal",0) AS "FreteGeral",
	COALESCE(i."LineTotal",0) AS "Frete",
	COALESCE(i."LineTotal",0) / o."Installmnt" AS "FretePorParcela",
	COALESCE(i."LineTotal",0) * (cv."Total pago" / NULLIF(o."DocTotal",0)) AS "FreteLinha",
	COALESCE(T8."LineTotal",0)*(cv."Total pago" / NULLIF(o."DocTotal",0)) AS "FreteLinha2",
	cv."Total pago" - COALESCE(i."LineTotal",0) AS "PagoSemFrete",
	(t5."LineTotal" / NULLIF(NV."TotalBruto",0)) AS "Percentual",
	(cv."Total pago" / NULLIF(o."DocTotal",0)) AS "Percentual2",
	round(((t5."LineTotal" / NULLIF(NV."TotalBruto",0)) * 100)*(o."DiscPrcnt" / 100),2) AS "%DescLinha",
	(ROUND((CV."Total pago" / NULLIF(O."DocTotal",	0)),2)* CV."Total pago")-COALESCE(I."LineTotal",0) AS "TotPgSFrete",
	((t5."LineTotal" / NULLIF(NV."TotalBruto",0))* CV."Total pago")-COALESCE(I."LineTotal",0) * (CV."Total pago" / NULLIF(O."DocTotal",0)) AS "TotPgSFrete2",
	(ROUND((t5."LineTotal" / NULLIF(NV."TotalBruto",0)),2)* CV."Total pago")-COALESCE(T8."LineTotal",0)*(cv."Total pago" / NULLIF(o."DocTotal",0)) AS "TotPgSFrete3",
	(cv."Total pago" * (t5."LineTotal" / NULLIF(NV."TotalBruto",0))) - COALESCE(i."LineTotal",0) / o."Installmnt" AS "TotPgSFrete4",
	(cv."Total pago" * (t5."LineTotal" / NULLIF(NV."TotalBruto",0))) - (COALESCE(T8."LineTotal",0)/ct."NumDesdobr")*(t5."LineTotal" / NULLIF(NV."TotalBruto",0)) AS "TotPgSFrete5",
	cv."Total pago" - (COALESCE(i."LineTotal",0) / o."Installmnt") AS "TotPgSFrete6"
FROM
	CR_VALORPAGO cv
LEFT JOIN NFS_FRETELINHA i ON 
	CV."EntryNota" = I."DocEntry"
LEFT JOIN OINV o ON 
	CV."EntryNota" = O."DocEntry"
LEFT JOIN "INV1" T5 ON
	i."DocEntry" = T5."DocEntry" AND I."LineNum" = t5."LineNum"
LEFT JOIN NFS_VALORBRUTO NV ON
	CV."EntryNota" = NV."DocEntry"
LEFT JOIN "INV3" T8 ON
	o."DocEntry" = T8."DocEntry"
inner JOIN NFS_NUMITENSNOTA NN ON 
	o."DocEntry" = NN."DocEntry"
LEFT JOIN CR_TITULOSDESDOBRADO ct ON 
	o."DocEntry" = ct."DocEntry"
INNER JOIN DLN1 d ON 
	o."DocEntry" = d."BaseEntry" AND i."ItemCode" = d."ItemCode"
WHERE
	o."CANCELED" = 'N'
	AND o."DocDate" >= TO_DATE(20230701,'YYYYMMDD')
	AND o."U_Rov_Refaturamento" = 'NAO'
	AND o."DpmAmnt" = 0 --QUANDO É UMA NOTA FISCAL DE SAIDA NORMAL
	AND o."isIns" = 'Y' 
	
	UNION 
	
	SELECT DISTINCT 
	'Fatura Adiantamento de Cliente' AS "Tipo",
	CV."EntryNota",
	O."DocNum", 
	T5."BaseLine",
	cv."N.Pag",
	cv."EntryPag",
	cv."DocLine",
	o."Installmnt" AS "Prestação",
	nn."N.Itens",
	cv."Total pago",
	cv."Total pago"*(t5."LineTotal" / NULLIF(NV."TotalBruto",0)) AS "TotalPago2",
	o."PaidSum",
	t5."LineTotal",
	COALESCE(T8."LineTotal",0) AS "FreteGeral",
	COALESCE(i."LineTotal",0) AS "Frete",
	COALESCE(i."LineTotal",0) / o."Installmnt" AS "FretePorParcela",
	COALESCE(i."LineTotal",0) * (t1."DrawnSum" / NULLIF(o."DpmAmnt",0)) AS "FreteLinha",
	COALESCE(T8."LineTotal",0)*(t1."DrawnSum" / NULLIF(o."DpmAmnt",0)) AS "FreteLinha2",
	cv."Total pago" - COALESCE(i."LineTotal",0) AS "PagoSemFrete",
	(t5."LineTotal" / NULLIF(NV."TotalBruto",0)) AS "Percentual",
	(cv."Total pago" / NULLIF(o."DpmAmnt",0)) AS "Percentual2",
	round(((t5."LineTotal" / NULLIF(NV."TotalBruto",0)) * 100)*(o."DiscPrcnt" / 100),2) AS "%DescLinha",
	(ROUND((CV."Total pago" / NULLIF(o."DpmAmnt",	0)),2)* CV."Total pago")-COALESCE(I."LineTotal",0) AS "TotPgSFrete",
	((t5."LineTotal" / NULLIF(NV."TotalBruto",0))* CV."Total pago")-COALESCE(I."LineTotal",0) * (CV."Total pago" / NULLIF(o."DpmAmnt",0)) AS "TotPgSFrete2",
	(ROUND((t5."LineTotal" / NULLIF(NV."TotalBruto",0)),2)* CV."Total pago")-COALESCE(T8."LineTotal",0)*(cv."Total pago" / NULLIF(o."DpmAmnt",0)) AS "TotPgSFrete3",
	(cv."Total pago" * (t5."LineTotal" / NULLIF(NV."TotalBruto",0))) - COALESCE(i."LineTotal",0) / o."Installmnt" AS "TotPgSFrete4",
	(cv."Total pago" * (t5."LineTotal" / NULLIF(NV."TotalBruto",0))) - (COALESCE(T8."LineTotal",0)/ct."NumDesdobr")*(t5."LineTotal" / NULLIF(NV."TotalBruto",0)) AS "TotPgSFrete5",
	cv."Total pago" - (COALESCE(i."LineTotal",0) / o."Installmnt") AS "TotPgSFrete6"
FROM
	CR_VALORPAGO cv
LEFT JOIN NFS_FRETELINHA i ON 
	CV."EntryNota" = I."DocEntry"
LEFT JOIN OINV o ON 
	CV."EntryNota" = O."DocEntry" AND O."DocType" = 'I' AND o."DpmAmnt" > 0 AND o."DocTotal" = 0
LEFT JOIN "INV1" T5 ON
	i."DocEntry" = T5."DocEntry" AND I."LineNum" = t5."LineNum"
LEFT JOIN NFS_VALORBRUTO NV ON
	CV."EntryNota" = NV."DocEntry"
LEFT JOIN "INV3" T8 ON
	o."DocEntry" = T8."DocEntry"
INNER JOIN NFS_NUMITENSNOTA NN ON 
	o."DocEntry" = NN."DocEntry"
LEFT JOIN INV9 T1 ON 
	O."DocEntry" = T1."DocEntry"
	AND cv."LineNum" = t1."LineNum"
LEFT JOIN ODPI T2 ON
	T1."BaseAbs" = T2."DocEntry"
LEFT JOIN CR_TITULOSDESDOBRADO ct ON 
	o."DocEntry" = ct."DocEntry"
WHERE 
	o."CANCELED" = 'N'
	AND o."DocDate" >= TO_DATE(20230701,'YYYYMMDD')
	AND o."U_Rov_Refaturamento" = 'NAO' --QUANDO A NOTA FISCAL DE SAIDA E ADIANTAMENTO