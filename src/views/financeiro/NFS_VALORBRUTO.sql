CREATE OR REPLACE VIEW NFS_VALORBRUTO AS
SELECT
	i."DocEntry",
	sum(i."LineTotal") AS "TotalBruto"
FROM
	INV1 i
GROUP BY
	i."DocEntry"

UNION
	
SELECT
	i."DocEntry",
	sum(i."LineTotal") AS "TotalBruto"
FROM
	DPI1 i
GROUP BY
	i."DocEntry";