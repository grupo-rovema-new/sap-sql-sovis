CREATE OR REPLACE VIEW ValidacaoParceiroNegocioSutenutri AS 
SELECT * FROM 
	(SELECT DISTINCT 
		CASE
			WHEN LENGTH(COALESCE("CardName",'0')) < 2 THEN 'Informe o nome/razao social do cliente'
			WHEN  e."Address" IS NOT NULL  THEN 'Remova os caracteres especiais do ID do endereco'
		END AS MSG,
		pn."CardCode"
	FROM
		OCRD AS pn
		INNER JOIN CRD8 pnf ON (pn."CardCode" = pnf."CardCode" AND pnf."BPLId" IN(2,4,11,17) AND pnf."DisabledBP" = 'N')
		LEFT JOIN CRD1 e on(pn."CardCode" = e."CardCode")
	WHERE 
		pn."CardType" = 'C'
		AND (fncRemove_Acentuacao(e."Address") <> UPPER(e."Address") OR e."Address" is NULL)
	)
WHERE
	LENGTH(MSG) > 2