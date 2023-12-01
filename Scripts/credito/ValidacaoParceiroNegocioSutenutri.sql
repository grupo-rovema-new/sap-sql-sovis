CREATE OR REPLACE VIEW ValidacaoParceiroNegocioSutenutri AS 
SELECT * FROM 
	(SELECT
		CASE
			WHEN LENGTH(COALESCE("CardName",'0')) < 2 THEN 'Informe o nome/razao social do cliente'
		END AS MSG,
		pn."CardCode"
	FROM
		OCRD AS pn
		INNER JOIN CRD8 pnf ON (pn."CardCode" = pnf."CardCode" AND pnf."BPLId" IN(2,4,11,17) AND pnf."DisabledBP" = 'N')
	WHERE 
		pn."CardType" = 'C'
	)
WHERE
	LENGTH(MSG) > 2
	

