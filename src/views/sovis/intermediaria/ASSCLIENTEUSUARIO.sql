CREATE OR REPLACE VIEW ASSCLIENTEUSUARIO AS 

	SELECT
		*
	FROM
		BASE_ASSCLIENTEUSUARIO	
		
	UNION ALL
	
	SELECT
		base."IDCLIENTEERP"  AS "IDCLIENTEERP",
		cord."codCordenador" AS "IDUSUARIOERP"
	FROM
		BASE_ASSCLIENTEUSUARIO base
		INNER JOIN cordenadorEstrutura cord ON base.IDUSUARIOERP = cord."codVendedor" 
	
	UNION ALL
	
	SELECT
		CLIENTE.IDCLIENTEERP  AS "IDCLIENTEERP",
		86 AS "IDUSUARIOERP"
	FROM
		CLIENTE
	
	UNION ALL
		
	SELECT
		CLIENTE.IDCLIENTEERP  AS "IDCLIENTEERP",
		45 AS "IDUSUARIOERP"
	FROM
		CLIENTE
		
	UNION ALL
	
	SELECT
		base."IDCLIENTEERP"  AS "IDCLIENTEERP",
		representante."vendedorSubordinado" AS "IDUSUARIOERP"
	FROM
		BASE_ASSCLIENTEUSUARIO base
		INNER JOIN representanteEstrutura representante ON base.IDUSUARIOERP = representante."vendedorSubordinado";
