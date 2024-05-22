-- Estrutura cordenador falta adicionar vendedores dos cordenadores
CREATE OR REPLACE VIEW CORDENADORESTRUTURA AS
	SELECT DISTINCT 
		cord."U_NomeCompleto" AS "nomeCordenador",
		cord."U_vendedor" AS "codCordenador",
		representante."U_NomeCompleto" AS "nomeVendedor",
		representante."U_CodVendedor" AS "codVendedor"
	FROM
		"@RO_CORDENADOR" cord
		INNER JOIN "@RO_REGIAO" reg ON cord."Code" = reg."U_CodCordenador"
		INNER JOIN "@RO_REGIAO_LINHAS" loc ON loc."Code" = reg."Code"
		INNER JOIN "@RO_REP_LINHAS" repLoc ON loc."U_Locais" = REPLOC."U_Localidades"
		INNER JOIN "@RO_REPRESENTANTE" representante ON repLoc."Code" = representante."Code"
	WHERE
		REPRESENTANTE."U_CodVendedor" IS NOT NULL AND cord."U_vendedor" IS NOT null
	
		UNION all
	
	SELECT DISTINCT 
		cord."U_NomeCompleto" AS "nomeCordenador",
		cord."U_vendedor" AS "codCordenador",
		VENDEDOr."SlpName" AS "nomeVendedor",
		VENDEDOr."SlpCode"  AS "codVendedor"
	FROM
		"@RO_CORDENADOR" cord
		INNER JOIN "@RO_REGIAO" reg ON cord."Code" = reg."U_CodCordenador"
		INNER JOIN "@RO_REGIAO_LINHAS" loc ON loc."Code" = reg."Code"
		INNER JOIN "@RO_REP_LINHAS" repLoc ON loc."U_Locais" = REPLOC."U_Localidades"
		INNER JOIN "@RO_REPRESENTANTE" representante ON repLoc."Code" = representante."Code"
		INNER JOIN OSLP vendedor ON vendedor."U_CodRepresentante" = REPRESENTANTE."Code" AND vendedor."SlpCode" !=  representante."U_CodVendedor"
	WHERE
		REPRESENTANTE."U_CodVendedor" IS NOT NULL AND cord."U_vendedor" IS NOT NULL;