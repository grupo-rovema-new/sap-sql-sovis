CREATE OR REPLACE VIEW CLIENTES_VA AS
SELECT 
	T0."CardCode" AS "IDCLIENTEERP",
	T0."CardName" AS "NOME",
	T0."CardName" AS "RSOCIAL",
	(SELECT cpfCnpj FROM BpCpfCnpj t 
	  WHERE T0."CardCode" = t."CardCode" 
	  AND (SELECT count(1) 
	         FROM BpCpfCnpj t 
	        WHERE T0."CardCode" = t."CardCode") <= 1) AS "CNPJCPF"	
FROM OCRD T0
WHERE T0."CardType" = 'C' AND exists(SELECT 1 FROM CRD8 WHERE T0."CardCode" = CRD8."CardCode" AND CRD8."BPLId" in(SELECT IDEMPRESAERP FROM EMPRESA))