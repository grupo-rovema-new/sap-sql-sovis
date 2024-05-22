CREATE OR REPLACE VIEW freteFaturamento as
SELECT
	"PK",	
	"BPLName",
	"numeroNota",
	"data",
	SUM(frete)
FROM 
	(SELECT
		f."BPLName",
		f."PK",
		f."numeroNota",
		"data",
		max(COALESCE(frete,0)) frete
	FROM
		faturamentoAndrew AS f
	GROUP BY
		f."BPLName",
		f."PK",
		"data",
		f."numeroNota")
WHERE
	frete > 0
GROUP BY
	"PK",	
	"BPLName",
	"data",
	"numeroNota"