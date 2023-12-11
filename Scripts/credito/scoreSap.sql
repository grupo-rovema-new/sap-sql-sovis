CREATE OR REPLACE VIEW scoreSap AS
	SELECT
		CASE 
			WHEN EXISTS(SELECT 1 FROM ValidacaoParceiroNegocioPrazoSutenutri AS c WHERE c."CardCode" = pn."CardCode") THEN false
			ELSE true
		END AS "atualizado",
		CASE
			WHEN EXISTS(SELECT 1 FROM ClienteInadimplentes AS c WHERE c."CardCode" = pn."CardCode") THEN true 
			ELSE false
		END AS "inadimplente",
		CASE
			WHEN EXISTS(SELECT 1 FROM mauPagador AS c WHERE c."CardCode" = pn."CardCode") THEN false 
			ELSE true
		END AS "PagaEmDia",
		CASE
			WHEN EXISTS(SELECT 1 FROM mauPagador AS c WHERE c."CardCode" = pn."CardCode" AND c."DocDate" > ADD_DAYS(NOW(),-180)) THEN false 
			ELSE true
		END AS "PagaEmDia 180 Dias"
	FROM
		OCRD pn

