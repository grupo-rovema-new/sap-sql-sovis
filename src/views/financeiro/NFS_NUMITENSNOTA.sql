CREATE OR REPLACE VIEW NFS_NUMITENSNOTA AS
SELECT
	I."DocEntry",
	count(I."DocEntry") AS "N.Itens"
FROM
	inv1 i
GROUP BY
	I."DocEntry";