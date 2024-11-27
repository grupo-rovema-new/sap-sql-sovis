CREATE OR REPLACE VIEW NFS_FATURADO AS
SELECT
	DISTINCT 
    T0."DocEntry" AS "EntryNota",
	T0."DocNum" AS "DocNum",
	COALESCE(T5."BaseLine",0) AS "BaseLine",
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
		T0."DocEntry" = T5."DocEntry"