CREATE OR REPLACE VIEW NFS_FATURADO AS
SELECT --Nota Fiscal de Saída
	DISTINCT 
    T0."DocEntry" AS "EntryNota",
	T0."DocNum" AS "DocNum",
	COALESCE(T5."BaseLine",0) AS "BaseLine",
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
		T0."DocEntry" = T5."DocEntry"
		
UNION		
		
SELECT --Fatura de Adiantamento de clientes
	DISTINCT 
    T0."DocEntry" AS "EntryNota",
	T0."DocNum" AS "DocNum",
	COALESCE(T5."BaseLine",0) AS "BaseLine",
	INV."Serial" AS "Nota Fiscal",
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
				"DPI4" tax
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
				"DPI4" tax
		WHERE
				tax."DocEntry" = T5."DocEntry"
			AND tax."staType" = 25
			AND tax."LineNum" = T5."LineNum"),
			0)
	END AS "faturado"
FROM
	ODPI T0
INNER JOIN DPI1 T5 ON
		T0."DocEntry" = T5."DocEntry"
LEFT JOIN 
    ORIN RIN -- Tabela de notas de crédito
    ON RIN."ReceiptNum" = T0."DocNum" -- Conexão por referência de recibo
LEFT JOIN 
    RCT2 PAYMENTS
    ON PAYMENTS."DocEntry" = T0."DocEntry"
LEFT JOIN 
    OINV INV
    ON INV."DocEntry" = PAYMENTS."DocEntry"
LEFT JOIN 
    OINV INV
    ON INV."DocEntry" = PAYMENTS."DocEntry"
WHERE 
    DPI.CANCELED = 'N'; -- Apenas pagamentos ativos