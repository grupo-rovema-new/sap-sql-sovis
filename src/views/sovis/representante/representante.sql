CREATE OR REPLACE VIEW representanteEstrutura AS
	SELECT
		v."SlpCode"  AS "vendedorSubordinado",
		v."SlpName"  AS "nomeVendedor",
		r."U_CodVendedor" AS "representante",
		r."U_NomeCompleto" AS "nomeRepresentante"
	FROM
		"@RO_REPRESENTANTE" AS r
		LEFT JOIN "OSLP" v ON  v."U_CodRepresentante" = r."Code" 
	WHERE
		r."U_CodVendedor" IS NOT NULL
		AND v."SlpCode" != r."U_CodVendedor";
