	CREATE OR REPLACE VIEW ESTADOS_VA AS
SELECT
	T0."Code" AS "IDESTADOERP",
	T0."Name" AS "DESCRICAO" 
FROM OCST T0 
WHERE LENGTH(T0."Code") <= 2;