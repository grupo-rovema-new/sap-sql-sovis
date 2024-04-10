CREATE OR REPLACE VIEW clienteSituacao as
SELECT
	"IDCLIENTEERP",
	CASE
		WHEN idade >= 180 THEN '6m'
		WHEN idade >= 4*30 THEN '4m'
		WHEN idade >= 60 THEN '60d'
		WHEN idade >= 30 THEN '30d'
		WHEN idade < 30 THEN 'dia'
		ELSE 'sh'
	END,
	idade
FROM 
	(SELECT DISTINCT 
		"IDCLIENTEERP",
		DAYS_BETWEEN((SELECT MAX("data") FROM FATURAMENTO f WHERE  "faturado" > 0 AND "CardCode" = IDCLIENTEERP),CURRENT_DATE) AS idade
	FROM
		CLIENTE)


