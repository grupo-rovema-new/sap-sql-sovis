CREATE OR REPLACE VIEW OrdemAtualizacaoCadastral AS
	SELECT
		MAX(v.MSG),
		pn."CardCode",
		pn."CardName",
		MAX(p."DocDate"),
		COUNT(p."DocEntry") AS NumeroEventos
	FROM
		OCRD pn
		INNER JOIN ValidacaoParceiroNegocioPrazoSutenutri v on(v."CardCode" = pn."CardCode")
		LEFT JOIN ORDR p on(pn."CardCode" = p."CardCode")
	GROUP BY
		pn."CardCode",
		pn."CardName"
	ORDER BY
		COUNT(p."DocEntry") DESC,
		MAX(p."DocDate") DESC,
		pn."CardCode"
