CREATE OR REPLACE VIEW inadimplenciaSoma as
SELECT
	pn."CardCode",
	pn."CardName",
	endereco."State",
	cidade."Name",
	sum(dev."InsTotal")
FROM
	OCRD pn
	LEFT JOIN CRD1 endereco ON (pn."CardCode" = endereco."CardCode" AND "AdresType" = 'S')
	INNER JOIN ClienteInadimplentes dev on(dev."CardCode" = pn."CardCode")
	LEFT JOIN OCNT cidade ON endereco."County" = cidade."AbsId"
GROUP BY 
	pn."CardCode",
	pn."CardName",
	endereco."State",
	cidade."Name"

	
	
--	
--
--SELECT * FROM CRD1 WHERE "AdresType" = 'S'
--
--
