CREATE OR REPLACE VIEW NFS_FRETELINHA AS
SELECT
	I."DocEntry",
	I."LineNum",
	I."BaseRef",
	I."ItemCode",
	COALESCE(I2."LineTotal",0) AS "LineTotal" 
FROM
	inv1 i
LEFT JOIN INV13 i2 ON
	I."DocEntry" = I2."DocEntry"
	AND I."LineNum" = I2."LineNum";