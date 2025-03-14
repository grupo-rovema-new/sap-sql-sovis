CREATE OR REPLACE VIEW NFS_PAGTOCOMISSAO AS
(SELECT
	'Nota Fiscal de Saída' AS "Tipo",
	T0."DocEntry" AS "EntryNota",
	T0."DocNum" AS "DocNum",
	T2."DocNum" AS "N.Pag",
	T5."BaseLine",
	COALESCE(T8."LineTotal",0) AS "FreteGeral", 
	T0."DocTotal",
	t1."DocLine",
	FA."faturado",
	COALESCE(T10."DocTotal",0) AS "Devolução",
	VP."Total pago",
	VP."Total pago" * f."Percentual",
	NT."Referenciado",
	nd."Devolução" AS "Dev", 
	CT."NumDesdobr",
	f."Prestação",
	f."N.Itens",
	t5."LineTotal" AS "TotalItem",
	f."Frete",
	f."FreteLinha",
	f."FreteLinha2",
	f."PagoSemFrete",
	f."Percentual",
	f."Percentual2",
	f."%DescLinha",
	CASE 
		WHEN F."N.Itens" > 1 AND f."Prestação" = 1 AND CT."NumDesdobr" > 1 AND COALESCE(T10."DocTotal",0) = 0 THEN f."TotPgSFrete"
		WHEN F."N.Itens" > 1 AND f."Prestação" = 1 AND CT."NumDesdobr" > 1 AND COALESCE(T10."DocTotal",0) > 0 AND NT."Referenciado" = 1 THEN f."TotPgSFrete2"
		WHEN F."N.Itens" > 1 AND f."Prestação" = 1 AND CT."NumDesdobr" > 1 AND COALESCE(T10."DocTotal",0) > 0 AND NT."Referenciado" > 1 THEN f."TotPgSFrete5"
		WHEN F."N.Itens" > 1 AND f."Prestação" = 1 AND CT."NumDesdobr" = 1 THEN f."TotPgSFrete2"
		WHEN f."N.Itens" > 1 AND f."Prestação" > 1 AND CT."NumDesdobr" > 1 AND COALESCE(T10."DocTotal",0) = 0 THEN f."TotPgSFrete2"
		WHEN f."N.Itens" > 1 AND f."Prestação" > CT."NumDesdobr" THEN f."TotPgSFrete2"
		WHEN F."N.Itens" > 1 AND F."Prestação" < CT."NumDesdobr" THEN f."TotPgSFrete2"
		WHEN F."N.Itens" > 1 AND f."Prestação" = CT."NumDesdobr" AND COALESCE(T10."DocTotal",0) > 0 THEN f."TotPgSFrete4"
		WHEN F."N.Itens" = 1 AND f."Prestação" = 1 AND CT."NumDesdobr" = 1 AND COALESCE(T10."DocTotal",0) = 0 THEN f."TotPgSFrete"
		WHEN F."N.Itens" = 1 AND f."Prestação" = 1 AND CT."NumDesdobr" = 1 AND COALESCE(T10."DocTotal",0) > 0 THEN f."TotPgSFrete2"
		WHEN f."N.Itens" = 1 AND f."Prestação" = 1 AND CT."NumDesdobr" > 1 THEN f."TotPgSFrete2"
		WHEN f."N.Itens" = 1 AND f."Prestação" >= CT."NumDesdobr" THEN f."TotPgSFrete3"
		WHEN f."N.Itens" = 1 AND f."Prestação" < CT."NumDesdobr" THEN f."TotPgSFrete"
		WHEN f."N.Itens" = 1 AND f."Prestação" = CT."NumDesdobr"  THEN f."TotPgSFrete2"
	END AS "PagoLiq",
	f."TotPgSFrete",
	f."TotPgSFrete2",
	f."TotPgSFrete3",
	f."TotPgSFrete4",
	f."TotPgSFrete5",
	f."TotPgSFrete6"
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
INNER JOIN "INV1" T5 ON
		T0."DocEntry" = T5."DocEntry"
LEFT JOIN "INV3" T8 ON
		T0."DocEntry" = T8."DocEntry"
LEFT JOIN RIN1 T9 ON
		T0."DocEntry" = T9."BaseEntry"
LEFT JOIN ORIN T10 ON
		T9."DocEntry" = T10."DocEntry"
LEFT JOIN CR_VALORPAGO VP ON 
		T0."DocEntry" = VP."EntryNota"
	AND T2."DocNum" = VP."N.Pag"
	AND T2."DocEntry" = VP."EntryPag"
	AND t1."DocLine" = vp."DocLine"
INNER JOIN "NFS_FATURADO" FA ON
		T0."DocEntry" = FA."EntryNota"
	AND T0."DocNum" = FA."DocNum"
	AND T5."BaseLine" = FA."BaseLine"
LEFT JOIN CR_TITULOSDESDOBRADO ct ON 
		T0."DocEntry" = CT."DocEntry"
	AND T0."DocNum" = CT."DocNum"
LEFT JOIN NFS_FRETE F ON
		T0."DocEntry" = F."EntryNota" 
	AND T2."DocNum" = F."N.Pag"
	AND T5."BaseLine" = f."BaseLine"
	AND t1."DocLine" = f."DocLine"
LEFT JOIN NFS_TITREF nt ON
		T0."DocEntry" = NT."DocEntry" 
	AND T0."DocNum" = NT."DocNum"
LEFT JOIN NFS_TITDEV nd ON 
		t0."DocEntry" = nd."DocEntry" 
	AND t0."DocNum" = nd."DocNum" 
WHERE 
		T0."CANCELED" = 'N'
	AND T0."DocDate" >= TO_DATE(20230701,'YYYYMMDD')
	AND T0."U_Rov_Refaturamento" = 'NAO'
	AND T0."isIns" = 'N') UNION ALL (SELECT
	'Nota Fiscal Entrega Futura' AS "Tipo",
	T0."DocEntry" AS "EntryNota",
	T0."DocNum" AS "DocNum",
	T2."DocNum" AS "N.Pag",
	T5."BaseLine",
	COALESCE(T8."LineTotal",0) AS "FreteGeral", 
	T0."DocTotal",
	t1."DocLine",
	FA."faturado",
	COALESCE(T10."DocTotal",0) AS "Devolução",
	VP."Total pago",
	VP."Total pago" * f."Percentual",
	NT."Referenciado",
	nd."Devolução" AS "Dev", 
	CT."NumDesdobr",
	f."Prestação",
	f."N.Itens",
	t5."LineTotal" AS "TotalItem",
	f."Frete",
	f."FreteLinha",
	f."FreteLinha2",
	f."PagoSemFrete",
	f."Percentual",
	f."Percentual2",
	f."%DescLinha",
	CASE 
		WHEN F."N.Itens" > 1 AND f."Prestação" = 1 AND CT."NumDesdobr" > 1 AND COALESCE(T10."DocTotal",0) = 0 THEN f."TotPgSFrete"
		WHEN F."N.Itens" > 1 AND f."Prestação" = 1 AND CT."NumDesdobr" > 1 AND COALESCE(T10."DocTotal",0) > 0 AND NT."Referenciado" = 1 THEN f."TotPgSFrete2"
		WHEN F."N.Itens" > 1 AND f."Prestação" = 1 AND CT."NumDesdobr" > 1 AND COALESCE(T10."DocTotal",0) > 0 AND NT."Referenciado" > 1 THEN f."TotPgSFrete5"
		WHEN F."N.Itens" > 1 AND f."Prestação" = 1 AND CT."NumDesdobr" = 1 THEN f."TotPgSFrete2"
		WHEN f."N.Itens" > 1 AND f."Prestação" > 1 AND CT."NumDesdobr" > 1 AND COALESCE(T10."DocTotal",0) = 0 THEN f."TotPgSFrete2"
		WHEN f."N.Itens" > 1 AND f."Prestação" > CT."NumDesdobr" THEN f."TotPgSFrete2"
		WHEN F."N.Itens" > 1 AND F."Prestação" < CT."NumDesdobr" THEN f."TotPgSFrete2"
		WHEN F."N.Itens" > 1 AND f."Prestação" = CT."NumDesdobr" AND nd."Devolução" > 0 AND NT."Referenciado" = 0 THEN f."TotPgSFrete4"
		WHEN F."N.Itens" > 1 AND f."Prestação" = CT."NumDesdobr" AND nd."Devolução" > 0 AND NT."Referenciado" > 0 THEN f."TotPgSFrete6"
		WHEN F."N.Itens" = 1 AND f."Prestação" = 1 AND CT."NumDesdobr" = 1 AND COALESCE(T10."DocTotal",0) = 0 THEN f."TotPgSFrete"
		WHEN F."N.Itens" = 1 AND f."Prestação" = 1 AND CT."NumDesdobr" = 1 AND COALESCE(T10."DocTotal",0) > 0 THEN f."TotPgSFrete2"
		WHEN f."N.Itens" = 1 AND f."Prestação" = 1 AND CT."NumDesdobr" > 1 THEN f."TotPgSFrete2"
		WHEN f."N.Itens" = 1 AND f."Prestação" >= CT."NumDesdobr" THEN f."TotPgSFrete3"
		WHEN f."N.Itens" = 1 AND f."Prestação" < CT."NumDesdobr" THEN f."TotPgSFrete"
		WHEN f."N.Itens" = 1 AND f."Prestação" = CT."NumDesdobr"  THEN f."TotPgSFrete2"
	END AS "PagoLiq",
	f."TotPgSFrete",
	f."TotPgSFrete2",
	f."TotPgSFrete3",
	f."TotPgSFrete4",
	f."TotPgSFrete5",
	f."TotPgSFrete6"
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
INNER JOIN "INV1" T5 ON
		T0."DocEntry" = T5."DocEntry"
LEFT JOIN "INV3" T8 ON
		T0."DocEntry" = T8."DocEntry"
LEFT JOIN RIN1 T9 ON
		T0."DocEntry" = T9."BaseEntry"
LEFT JOIN ORIN T10 ON
		T9."DocEntry" = T10."DocEntry"
LEFT JOIN CR_VALORPAGO VP ON 
		T0."DocEntry" = VP."EntryNota"
	AND T2."DocNum" = VP."N.Pag"
	AND T2."DocEntry" = VP."EntryPag"
	AND t1."DocLine" = vp."DocLine"
INNER JOIN "NFS_FATURADO" FA ON
		T0."DocEntry" = FA."EntryNota"
	AND T0."DocNum" = FA."DocNum"
	AND T5."BaseLine" = FA."BaseLine"
LEFT JOIN CR_TITULOSDESDOBRADO ct ON 
		T0."DocEntry" = CT."DocEntry"
	AND T0."DocNum" = CT."DocNum"
LEFT JOIN NFS_FRETE F ON
		T0."DocEntry" = F."EntryNota" 
	AND T2."DocNum" = F."N.Pag"
	AND T5."BaseLine" = f."BaseLine"
	AND t1."DocLine" = f."DocLine"
LEFT JOIN NFS_TITREF nt ON
		T0."DocEntry" = NT."DocEntry" 
	AND T0."DocNum" = NT."DocNum"
LEFT JOIN NFS_TITDEV nd ON 
		t0."DocEntry" = nd."DocEntry" 
	AND t0."DocNum" = nd."DocNum"
INNER JOIN DLN1 d ON 
	T0."DocEntry" = d."BaseEntry" AND T5."ItemCode" = d."ItemCode"
WHERE 
		T0."CANCELED" = 'N'
	AND T0."DocDate" >= TO_DATE(20230701,'YYYYMMDD')
	AND T0."U_Rov_Refaturamento" = 'NAO'
	AND T0."isIns" = 'Y')) UNION ALL (SELECT
	'Fatura Adiantamento de Cliente' AS "Tipo",
	T0."DocEntry" AS "EntryNota",
	T0."DocNum" AS "DocNum",
	T2."DocNum" AS "N.Pag",
	T5."BaseLine",
	COALESCE(T8."LineTotal",0) AS "FreteGeral", 
	T14."DocTotal",
	t1."DocLine",
	FA."faturado",
	COALESCE(T10."DocTotal",0) AS "Devolução",
	VP."Total pago",
	VP."Total pago" * f."Percentual",
	NT."Referenciado", 
	nd."Devolução" AS "Dev",
	CT."NumDesdobr",
	f."Prestação",
	f."N.Itens",
	t5."LineTotal" AS "TotalItem",
	f."Frete",
	f."FreteLinha",
	f."FreteLinha2",
	f."PagoSemFrete",
	f."Percentual",
	f."Percentual2",
	f."%DescLinha",
	CASE 
		WHEN F."N.Itens" > 1 AND f."Prestação" = 1 AND CT."NumDesdobr" > 1 AND COALESCE(T10."DocTotal",0) = 0 THEN f."TotPgSFrete"
		WHEN F."N.Itens" > 1 AND f."Prestação" = 1 AND CT."NumDesdobr" > 1 AND COALESCE(T10."DocTotal",0) > 0 THEN f."TotPgSFrete2"
		WHEN F."N.Itens" > 1 AND f."Prestação" = 1 AND CT."NumDesdobr" = 1 THEN f."TotPgSFrete2"
		WHEN f."N.Itens" > 1 AND f."Prestação" > 1 AND CT."NumDesdobr" > 1 AND COALESCE(T10."DocTotal",0) = 0 THEN f."TotPgSFrete2"
		WHEN f."N.Itens" > 1 AND f."Prestação" > CT."NumDesdobr" THEN f."TotPgSFrete2"
		WHEN F."N.Itens" > 1 AND F."Prestação" < CT."NumDesdobr" THEN  f."TotPgSFrete2"
		WHEN F."N.Itens" > 1 AND f."Prestação" = CT."NumDesdobr" AND COALESCE(T10."DocTotal",0) > 0 THEN f."TotPgSFrete4"
		WHEN F."N.Itens" = 1 AND f."Prestação" = 1 AND CT."NumDesdobr" = 1 AND COALESCE(T10."DocTotal",0) = 0 THEN f."TotPgSFrete"
		WHEN F."N.Itens" = 1 AND f."Prestação" = 1 AND CT."NumDesdobr" = 1 AND COALESCE(T10."DocTotal",0) > 0 THEN f."TotPgSFrete2"
		WHEN f."N.Itens" = 1 AND f."Prestação" = 1 AND CT."NumDesdobr" > 1 THEN f."TotPgSFrete2"
		WHEN f."N.Itens" = 1 AND f."Prestação" >= CT."NumDesdobr" THEN f."TotPgSFrete3"
		WHEN f."N.Itens" = 1 AND f."Prestação" < CT."NumDesdobr" THEN f."TotPgSFrete"
		WHEN f."N.Itens" = 1 AND f."Prestação" = CT."NumDesdobr"  THEN f."TotPgSFrete2"
	END AS "PagoLiq",
	f."TotPgSFrete",
	f."TotPgSFrete2",
	f."TotPgSFrete3",
	f."TotPgSFrete4",
	f."TotPgSFrete5",
	f."TotPgSFrete6"
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
INNER JOIN CR_VALORPAGO VP ON 
		T0."DocEntry" = VP."EntryNota"
	AND T2."DocNum" = VP."N.Pag"
	AND T2."DocEntry" = VP."EntryPag"
	AND t1."DocLine" = vp."DocLine"
LEFT JOIN "NFS_FATURADO" FA ON
		T0."DocEntry" = FA."EntryNota"
	AND T0."DocNum" = FA."DocNum"
	AND T5."BaseLine" = FA."BaseLine"
LEFT JOIN CR_TITULOSDESDOBRADO ct ON 
		T0."DocEntry" = CT."DocEntry"
	AND T0."DocNum" = CT."DocNum"
LEFT JOIN NFS_VALORBRUTO NV ON
		T0."DocEntry" = NV."DocEntry"
LEFT JOIN NFS_FRETE f ON
		T0."DocEntry" = F."EntryNota" 
	AND T2."DocNum" = F."N.Pag"
	AND T5."BaseLine" = f."BaseLine"
	AND t1."DocLine" = f."DocLine"
LEFT JOIN NFS_TITREF nt ON
		T0."DocEntry" = NT."DocEntry" 
	AND T0."DocNum" = NT."DocNum" 
LEFT JOIN NFS_TITDEV nd ON
		T0."DocEntry" = nd."DocEntry" 
	AND T0."DocNum" = nd."DocNum"
WHERE 
		T0."CANCELED" = 'N'
	AND T0."DocDate" >= TO_DATE(20230701,'YYYYMMDD')
	AND T0."U_Rov_Refaturamento" = 'NAO'
	AND t5."BaseLine" IS NOT NULL);