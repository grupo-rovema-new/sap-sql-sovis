CREATE OR REPLACE VIEW PRAZOPAGTO AS 
	SELECT
		"GroupNum" AS "IDPRAZOPAGTOERP",
		"PymntGroup" AS "DESCRICAO",
		 1 AS "SITUACAO"
	FROM
		OCTG
WHERE octg."U_Rov_EnviarForca" = 1;