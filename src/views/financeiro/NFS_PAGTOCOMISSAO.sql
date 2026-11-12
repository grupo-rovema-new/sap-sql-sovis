

CREATE OR REPLACE VIEW NFS_PAGTOCOMISSAO AS
(((SELECT
	'Nota Fiscal de Saída' AS "Tipo",
	T0."DocEntry" AS "EntryNota",
	T0."DocNum" AS "DocNum",
	T2."DocNum" AS "N.Pag",
	T5."BaseLine",
	COALESCE(T8."LineTotal",0) AS "FreteGeral", 
	T0."DocTotal",
	t1."DocLine",
	FA."faturado",
	COALESCE(T10."DocTotal",0)*F."Percentual" AS "Devolução",
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
		-- Nota com adiantamento: o saldo pago na nota é só parte do total (DocTotal + DpmAmnt), então o frete sai na mesma proporção.
		-- O NFS_FRETE divide pelo DocTotal (só o saldo) e tira o frete inteiro de novo; num saldo de R$ 0,01 a base ficava negativa.
		WHEN T0."DpmAmnt" > 0 THEN T1."SumApplied" * FA."faturado" / NULLIF(T0."DocTotal" + T0."DpmAmnt", 0)
		WHEN F."N.Itens" = 1 AND f."Prestação" = 1 AND CT."NumDesdobr" = 1 AND NT."Referenciado" = 1 AND nd."Devolução" = 0 AND f."Frete" <> 0 AND t0."DocStatus" = 'C' THEN f."TotPgSFrete"
		WHEN F."N.Itens" = 1 AND f."Prestação" = 1 AND CT."NumDesdobr" = 1 AND NT."Referenciado" = 1 AND nd."Devolução" = 0 AND f."Frete" <> 0 AND t0."DocStatus" = 'O' THEN f."TotPgSFrete2"
		WHEN F."N.Itens" > 1 AND f."Prestação" = 1 AND CT."NumDesdobr" = 1 AND NT."Referenciado" = 1 AND nd."Devolução" = 0 AND f."Frete" = 0 THEN f."TotPgSFrete2"
		WHEN F."N.Itens" = 1 AND f."Prestação" = 1 AND CT."NumDesdobr" = 1 AND NT."Referenciado" = 1 AND nd."Devolução" <> 0 AND f."Frete" = 0 THEN f."TotPgSFrete"
		WHEN F."N.Itens" = 1 AND f."Prestação" = CT."NumDesdobr" AND NT."Referenciado" = 1 AND nd."Devolução" = 0 AND f."Frete" = 0 THEN f."TotPgSFrete2"
		WHEN F."N.Itens" > 1 AND f."Prestação" = CT."NumDesdobr" AND NT."Referenciado" = 1 AND nd."Devolução" = 0 AND f."Frete" <> 0 THEN f."TotPgSFrete2"
		WHEN F."N.Itens" = 1 AND f."Prestação" = CT."NumDesdobr" AND NT."Referenciado" = 1 AND nd."Devolução" = 0 AND f."Frete" <> 0 THEN f."TotPgSFrete2"
		WHEN F."N.Itens" > 1 AND f."Prestação" <> CT."NumDesdobr" AND NT."Referenciado" > 1 AND nd."Devolução" > 0 AND f."Frete" <> 0 THEN f."TotPgSFrete5"
		WHEN F."N.Itens" = 1 AND f."Prestação" <> CT."NumDesdobr" AND NT."Referenciado" = 1 AND nd."Devolução" = 0 AND f."Frete" <> 0 THEN f."TotPgSFrete2"
		WHEN F."N.Itens" > 1 AND f."Prestação" <> CT."NumDesdobr" AND NT."Referenciado" = 1 AND nd."Devolução" = 0 AND f."Frete" <> 0 THEN f."TotPgSFrete2"
		WHEN F."N.Itens" = 1 AND f."Prestação" < CT."NumDesdobr" AND NT."Referenciado" = 1 AND nd."Devolução" <> 0 AND f."Frete" <> 0 THEN f."TotPgSFrete2"
		WHEN F."N.Itens" > 1 AND f."Prestação" <> CT."NumDesdobr" AND NT."Referenciado" = 1 AND nd."Devolução" = 0 AND f."Frete" = 0 THEN f."TotPgSFrete2"
		WHEN F."N.Itens" = 1 AND f."Prestação" = 1 AND CT."NumDesdobr" > 1  AND NT."Referenciado" = 1 AND nd."Devolução" = 0 AND f."Frete" = 0 THEN f."TotPgSFrete2"
		WHEN F."N.Itens" > 1 AND f."Prestação" = CT."NumDesdobr" AND NT."Referenciado" = 1 AND nd."Devolução" = 1 AND f."Frete" = 0 THEN f."TotPgSFrete2"
		WHEN F."N.Itens" > 1 AND f."Prestação" = CT."NumDesdobr" AND NT."Referenciado" = 1 AND nd."Devolução" = 0 AND f."Frete" = 0 THEN f."TotPgSFrete2"
		WHEN F."N.Itens" > 1 AND f."Prestação" <> CT."NumDesdobr" AND NT."Referenciado" = 1 AND nd."Devolução" = 1 AND f."Frete" > 0 THEN f."TotPgSFrete2"
		WHEN F."N.Itens" = 1 AND f."Prestação" <> CT."NumDesdobr" AND NT."Referenciado" = 1 AND nd."Devolução" = 0 AND f."Frete" = 0 AND t0."DocStatus" = 'O' THEN f."TotPgSFrete2"
		WHEN F."N.Itens" = 1 AND f."Prestação" <> CT."NumDesdobr" AND NT."Referenciado" = 1 AND nd."Devolução" = 0 AND f."Frete" = 0 AND t0."DocStatus" = 'C' THEN f."TotPgSFrete2"
		WHEN F."N.Itens" = 1 AND f."Prestação" <> CT."NumDesdobr" AND NT."Referenciado" > 1 AND nd."Devolução" = 0 AND f."Frete" > 0 THEN f."TotPgSFrete2"
		ELSE f."TotPgSFrete2"
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
	AND T0."isIns" = 'N'
	AND CT."Tipo" = 'NS') UNION ALL (SELECT
    'Nota Fiscal Entrega Futura'    AS "Tipo",
    T0."DocEntry"                   AS "EntryNota",
    T0."DocNum"                     AS "DocNum",
    T2."DocNum"                     AS "N.Pag",
    T5."BaseLine",
    COALESCE(T8."LineTotal", 0)     AS "FreteGeral",
    T0."DocTotal",
    T1."DocLine",
    FA."faturado",
    COALESCE(T10."DocTotal", 0)*F."Percentual"     AS "Devolução",
    VP."Total pago",
    VP."Total pago" * F."Percentual",
    NT."Referenciado",
    ND."Devolução"                 AS "Dev",
    CT."NumDesdobr",
    F."Prestação",
    F."N.Itens",
    T5."LineTotal"                  AS "TotalItem",
    F."Frete",
    F."FreteLinha",
    F."FreteLinha2",
    F."PagoSemFrete",
    F."Percentual",
    F."Percentual2",
    F."%DescLinha",
    CASE
        -- Nota com adiantamento: mesma regra da nota fiscal de saída (frete proporcional ao total DocTotal + DpmAmnt)
        WHEN T0."DpmAmnt" > 0 THEN T1."SumApplied" * FA."faturado" / NULLIF(T0."DocTotal" + T0."DpmAmnt", 0)
        WHEN F."N.Itens" = 1  AND F."Prestação" = 1            AND CT."NumDesdobr" = 1  AND NT."Referenciado" = 1  AND ND."Devolução" = 0  AND F."Frete" <> 0 AND T0."DocStatus" = 'C' THEN F."TotPgSFrete"
        WHEN F."N.Itens" = 1  AND F."Prestação" = 1            AND CT."NumDesdobr" = 1  AND NT."Referenciado" = 1  AND ND."Devolução" = 0  AND F."Frete" <> 0 AND T0."DocStatus" = 'O' THEN F."TotPgSFrete2"
        WHEN F."N.Itens" > 1  AND F."Prestação" = 1            AND CT."NumDesdobr" = 1  AND NT."Referenciado" = 1  AND ND."Devolução" = 0  AND F."Frete" = 0                             THEN F."TotPgSFrete2"
        WHEN F."N.Itens" = 1  AND F."Prestação" = 1            AND CT."NumDesdobr" = 1  AND NT."Referenciado" = 1  AND ND."Devolução" <> 0 AND F."Frete" = 0                             THEN F."TotPgSFrete"
        WHEN F."N.Itens" = 1  AND F."Prestação" = CT."NumDesdobr"                        AND NT."Referenciado" = 1  AND ND."Devolução" = 0  AND F."Frete" = 0                             THEN F."TotPgSFrete2"
        WHEN F."N.Itens" > 1  AND F."Prestação" = CT."NumDesdobr"                        AND NT."Referenciado" = 1  AND ND."Devolução" = 0  AND F."Frete" <> 0                            THEN F."TotPgSFrete2"
        WHEN F."N.Itens" = 1  AND F."Prestação" = CT."NumDesdobr"                        AND NT."Referenciado" = 1  AND ND."Devolução" = 0  AND F."Frete" <> 0                            THEN F."TotPgSFrete2"
        WHEN F."N.Itens" > 1  AND F."Prestação" <> CT."NumDesdobr"                       AND NT."Referenciado" > 1  AND ND."Devolução" > 0  AND F."Frete" <> 0                            THEN F."TotPgSFrete5"
        WHEN F."N.Itens" = 1  AND F."Prestação" <> CT."NumDesdobr"                       AND NT."Referenciado" = 1  AND ND."Devolução" = 0  AND F."Frete" <> 0                            THEN F."TotPgSFrete2"
        WHEN F."N.Itens" > 1  AND F."Prestação" <> CT."NumDesdobr"                       AND NT."Referenciado" = 1  AND ND."Devolução" = 0  AND F."Frete" <> 0                            THEN F."TotPgSFrete2"
        WHEN F."N.Itens" = 1  AND F."Prestação" < CT."NumDesdobr"                        AND NT."Referenciado" = 1  AND ND."Devolução" <> 0 AND F."Frete" <> 0                            THEN F."TotPgSFrete2"
        WHEN F."N.Itens" > 1  AND F."Prestação" <> CT."NumDesdobr"                       AND NT."Referenciado" = 1  AND ND."Devolução" = 0  AND F."Frete" = 0                             THEN F."TotPgSFrete2"
        WHEN F."N.Itens" = 1  AND F."Prestação" = 1            AND CT."NumDesdobr" > 1  AND NT."Referenciado" = 1  AND ND."Devolução" = 0  AND F."Frete" = 0                             THEN F."TotPgSFrete2"
        WHEN F."N.Itens" > 1  AND F."Prestação" = CT."NumDesdobr"                        AND NT."Referenciado" = 1  AND ND."Devolução" = 1  AND F."Frete" = 0                             THEN F."TotPgSFrete2"
        WHEN F."N.Itens" > 1  AND F."Prestação" = CT."NumDesdobr"                        AND NT."Referenciado" = 1  AND ND."Devolução" = 0  AND F."Frete" = 0                             THEN F."TotPgSFrete2"
        WHEN F."N.Itens" > 1  AND F."Prestação" <> CT."NumDesdobr"                       AND NT."Referenciado" = 1  AND ND."Devolução" = 1  AND F."Frete" > 0                             THEN F."TotPgSFrete2"
        WHEN F."N.Itens" = 1  AND F."Prestação" <> CT."NumDesdobr"                       AND NT."Referenciado" = 1  AND ND."Devolução" = 0  AND F."Frete" = 0 AND T0."DocStatus" = 'O'   THEN F."TotPgSFrete2"
        WHEN F."N.Itens" = 1  AND F."Prestação" <> CT."NumDesdobr"                       AND NT."Referenciado" = 1  AND ND."Devolução" = 0  AND F."Frete" = 0 AND T0."DocStatus" = 'C'   THEN F."TotPgSFrete2"
        WHEN F."N.Itens" = 1  AND F."Prestação" <> CT."NumDesdobr"                       AND NT."Referenciado" > 1  AND ND."Devolução" = 0  AND F."Frete" > 0                             THEN F."TotPgSFrete2"
        ELSE F."TotPgSFrete2"
    END AS "PagoLiq",
    F."TotPgSFrete",
    F."TotPgSFrete2",
    F."TotPgSFrete3",
    F."TotPgSFrete4",
    F."TotPgSFrete5",
    F."TotPgSFrete6"

FROM OINV T0

INNER JOIN INV6 T3
    ON  T3."DocEntry" = T0."DocEntry"

INNER JOIN RCT2 T1
    ON  T1."DocEntry"    = T0."DocEntry"
    AND T1."DocTransId"  = T0."TransId"
    AND T1."InstId"      = T3."InstlmntID"

INNER JOIN ORCT T2
    ON  T2."DocEntry" = T1."DocNum"
    AND T2."Canceled" = 'N'

INNER JOIN INV1 T5
    ON  T0."DocEntry" = T5."DocEntry"

-- ✅ FIX 1: INV3 pode ter múltiplas linhas por DocEntry (ex: frete por linha)
--           Agregamos para trazer um único valor total por nota
LEFT JOIN (
    SELECT "DocEntry", SUM("LineTotal") AS "LineTotal"
    FROM INV3
    GROUP BY "DocEntry"
) T8
    ON T0."DocEntry" = T8."DocEntry"

-- ✅ FIX 2: RIN1 + ORIN geram duplicatas quando há mais de uma devolução
--           Agrupamos por BaseEntry + LineNum + ItemCode para garantir 1 linha por item
LEFT JOIN (
    SELECT
        R."BaseEntry",
        R."LineNum",
        R."ItemCode",
        SUM(O."DocTotal") AS "DocTotal"
    FROM RIN1 R
    INNER JOIN ORIN O ON R."DocEntry" = O."DocEntry"
    WHERE O.CANCELED = 'N'
    GROUP BY R."BaseEntry", R."LineNum", R."ItemCode"
) T10
    ON  T0."DocEntry"   = T10."BaseEntry"
    AND T5."LineNum"    = T10."LineNum"
    AND T5."ItemCode"   = T10."ItemCode"

LEFT JOIN CR_VALORPAGO VP
    ON  T0."DocEntry"   = VP."EntryNota"
    AND T2."DocNum"     = VP."N.Pag"
    AND T2."DocEntry"   = VP."EntryPag"
    AND T1."DocLine"    = VP."DocLine"

INNER JOIN NFS_FATURADO FA
    ON  T0."DocEntry" = FA."EntryNota"
    AND T0."DocNum"   = FA."DocNum"
    AND T5."BaseLine" = FA."BaseLine"

LEFT JOIN CR_TITULOSDESDOBRADO CT
    ON  T0."DocEntry" = CT."DocEntry"
    AND T0."DocNum"   = CT."DocNum"

LEFT JOIN NFS_FRETE F
    ON  T0."DocEntry" = F."EntryNota"
    AND T2."DocNum"   = F."N.Pag"
    AND T5."BaseLine" = F."BaseLine"
    AND T1."DocLine"  = F."DocLine"

LEFT JOIN NFS_TITREF NT
    ON  T0."DocEntry" = NT."DocEntry"
    AND T0."DocNum"   = NT."DocNum"

LEFT JOIN NFS_TITDEV ND
    ON  T0."DocEntry" = ND."DocEntry"
    AND T0."DocNum"   = ND."DocNum"

-- ✅ FIX 3: DLN1 pode ter múltiplas entregas para o mesmo item/linha
--           Mantemos apenas a primeira ocorrência via MIN(DocEntry)
LEFT JOIN (
    SELECT "BaseEntry", "ItemCode", "LineNum", MIN("DocEntry") AS "DocEntry"
    FROM DLN1
    GROUP BY "BaseEntry", "ItemCode", "LineNum"
) D
    ON  T0."DocEntry"  = D."BaseEntry"
    AND T5."ItemCode"  = D."ItemCode"
    AND T5."LineNum"   = D."LineNum"

WHERE
        T0."CANCELED"              = 'N'
    AND T0."DocDate"               >= TO_DATE(20230701, 'YYYYMMDD')
    AND T0."U_Rov_Refaturamento"   = 'NAO'
    AND T0."isIns"                 = 'Y'
    AND CT."Tipo"                  = 'NS')) UNION ALL (SELECT
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
	-- Parte deste pagamento do adiantamento que ficou nesta nota, sem o frete:
	--   aplicado no ODPI (RCT2) × usado na nota (INV9.DrawnSum, menos o que a devolução estornou na RIN9) ÷ total do ODPI
	--   × faturado sem frete ÷ total da nota (DocTotal + DpmAmnt).
	-- O NFS_FRETE usa o total do recibo (CR_VALORPAGO.DocTotal) como "Total pago": um ODPI repartido entre notas entrava
	-- inteiro em cada uma, e o frete inteiro saía de novo no pagamento do saldo da nota.
	T1."SumApplied" * (T13."DrawnSum" - COALESCE(DV."DrawnDev", 0)) / NULLIF(T14."DocTotal", 0)
		* FA."faturado" / NULLIF(T0."DocTotal" + T0."DpmAmnt", 0) AS "PagoLiq",
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
-- Adiantamento devolvido pela devolução da nota (o SAP o libera para a nota refaturada): uma linha por nota + ODPI
LEFT JOIN (
	SELECT R1."BaseEntry", R9."BaseAbs", SUM(R9."DrawnSum") AS "DrawnDev"
	FROM RIN9 R9
	INNER JOIN ORIN C ON
			C."DocEntry" = R9."DocEntry"
		AND C."CANCELED" = 'N'
	INNER JOIN (SELECT DISTINCT "DocEntry", "BaseEntry" FROM RIN1 WHERE "BaseType" = 13) R1 ON
			R1."DocEntry" = C."DocEntry"
	GROUP BY R1."BaseEntry", R9."BaseAbs"
) DV ON
		T0."DocEntry" = DV."BaseEntry"
	AND T13."BaseAbs" = DV."BaseAbs"
WHERE
		T0."CANCELED" = 'N'
	AND T0."DocDate" >= TO_DATE(20230701,'YYYYMMDD')
	AND T0."U_Rov_Refaturamento" = 'NAO'
	AND t5."BaseLine" IS NOT NULL
	AND CT."Tipo" = 'AT'));