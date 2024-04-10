CREATE OR REPLACE VIEW PedidosAbertoComClienteInadimplente AS
	SELECT
		p."DocNum",
		p."CardCode",
		p."CardName",
		p."DocDate",
		p."DocTotal",
		p."GroupNum",
		f."BPLName" 
	FROM 
		ORDR p
		LEFT JOIN OBPL f on(f."BPLId" = p."BPLId")
	WHERE 
		p."CardCode" in(SELECT "ShortName" FROM ClienteInadimplentesByContabilidade)
		AND CANCELED = 'N'
		AND "DocStatus" = 'O'
		AND "GroupNum" <> -1
	ORDER BY p."DocDate"  DESC





	
	    
	    
	    