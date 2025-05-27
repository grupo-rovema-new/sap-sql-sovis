CREATE OR REPLACE VIEW NFS_FATURADO AS ((
SELECT
	--Nota Fiscal de Saída
	DISTINCT 
    T0."DocEntry" AS "EntryNota",
	T0."DocNum" AS "DocNum",
	COALESCE(T5."BaseLine",
	0) AS "BaseLine",
	T0."Serial" AS "NotaFiscal",
	CASE
			WHEN T0."isIns" = 'Y' THEN  
	T5."LineTotal"-COALESCE((
		SELECT
				CASE 
					WHEN COALESCE(SUM("U_TX_VlDeL"),
					0) = 0 THEN COALESCE(SUM("TaxSum"),
					0)
				ELSE COALESCE(SUM("U_TX_VlDeL"),
					0)
			END
		FROM
				"INV4" tax
		WHERE
				tax."DocEntry" = T5."DocEntry"
			AND ( tax."staType" = 28
				OR tax."staType" = 10)
			AND tax."LineNum" = T5."LineNum"),
			0)
		ELSE T5."LineTotal"-COALESCE((
		SELECT
				CASE 
					WHEN COALESCE(SUM("U_TX_VlDeL"),
					0) = 0 THEN COALESCE(SUM("TaxSum"),
					0)
				ELSE COALESCE(SUM("U_TX_VlDeL"),
					0)
			END
		FROM
				"INV4" tax
		WHERE
				tax."DocEntry" = T5."DocEntry"
			AND tax."staType" = 25
			AND tax."LineNum" = T5."LineNum"),
			0)
	END AS "faturado"
FROM
	OINV T0
INNER JOIN "INV1" T5 ON
		T0."DocEntry" = T5."DocEntry")
UNION (
SELECT
	--Fatura de Adiantamento de clientes
	DISTINCT 
    T0."DocEntry" AS "EntryNota",
	T0."DocNum" AS "DocNum",
	COALESCE(T5."BaseLine",
	0) AS "BaseLine",
	T0."Serial" AS "NotaFiscal",
	CASE
			WHEN T0."isIns" = 'Y' THEN  
	T5."LineTotal"-COALESCE((
		SELECT
				CASE 
					WHEN COALESCE(SUM("U_TX_VlDeL"),
					0) = 0 THEN COALESCE(SUM("TaxSum"),
					0)
				ELSE COALESCE(SUM("U_TX_VlDeL"),
					0)
			END
		FROM
				"INV4" tax
		WHERE
				tax."DocEntry" = T5."DocEntry"
			AND ( tax."staType" = 28
				OR tax."staType" = 10)
			AND tax."LineNum" = T5."LineNum"),
			0)
		ELSE T5."LineTotal"-COALESCE((
		SELECT
				CASE 
					WHEN COALESCE(SUM("U_TX_VlDeL"),
					0) = 0 THEN COALESCE(SUM("TaxSum"),
					0)
				ELSE COALESCE(SUM("U_TX_VlDeL"),
					0)
			END
		FROM
				"INV4" tax
		WHERE
				tax."DocEntry" = T5."DocEntry"
			AND tax."staType" = 25
			AND tax."LineNum" = T5."LineNum"),
			0)
	END AS "faturado"
FROM
		OINV T0
INNER JOIN INV9 T12 ON
		T0."DocEntry" = T12."DocEntry"
INNER JOIN ODPI T14 ON
		T12."BaseDocNum" = T14."DocNum"
INNER JOIN "INV1" T5 ON
		T0."DocEntry" = T5."DocEntry"))