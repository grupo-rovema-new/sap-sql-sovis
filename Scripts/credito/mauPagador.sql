CREATE OR REPLACE VIEW mauPagador AS
	SELECT
		t."CardCode",
		t."DocDate",
		p."DueDate"
	FROM
		ORCT t
		LEFT JOIN RCT2 l ON t."DocEntry" = l."DocNum"
		INNER JOIN INV6 p ON p."DocEntry"  = l."DocEntry" AND p."InstlmntID" = l."InstId"
	WHERE
		"Canceled" = 'N'
		AND (t."DocDate" > ADD_DAYS(p."DueDate",2))