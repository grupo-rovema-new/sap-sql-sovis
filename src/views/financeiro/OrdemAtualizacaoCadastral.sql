CREATE OR REPLACE VIEW OrdemAtualizacaoCadastral AS
	SELECT DISTINCT 
		MAX(v.MSG),
		pn."CardCode",
		pn."CardName",
		MIN(i."DueDate") "Inadimplente desde",
		sum(i."InsTotal") AS valorInadimplente,
		(SELECT MAX("DocDate") FROM ORDR WHERE ORDR."CardCode" = pn."CardCode") AS "Data Pedido Aberto",
		pn."E_Mail",
		pn."Phone1", 
		pn."Phone2"
	FROM
		OCRD pn
		INNER JOIN ValidacaoParceiroNegocioPrazoSutenutri v on(v."CardCode" = pn."CardCode")
		LEFT JOIN CLIENTEINADIMPLENTES i on(i."CardCode" = pn."CardCode")
	WHERE
		pn."CardType" = 'C' AND
		(i."BPLId" in(2,4,11,17) OR i."BPLId" IS null)
	GROUP BY
		pn."CardCode",
		pn."E_Mail",
		pn."Phone1", 
		pn."Phone2",
		pn."CardName"
	ORDER BY
		sum(i."InsTotal") DESC,
		(SELECT MAX("DocDate") FROM ORDR WHERE ORDR."CardCode" = pn."CardCode") DESC,
		pn."CardCode"
		
		