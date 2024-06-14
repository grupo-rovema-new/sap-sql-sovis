CREATE OR REPLACE VIEW CLIENTE_VA AS
SELECT
		OCRD."CardCode" AS "IDCLIENTEERP",
		"CardName"  AS "NOME",
		"CardName"  AS "RSOCIAL",
		OCRD."Address"  AS "ENDERECO",
		"Number"  AS "NUMERO",
		OCRD."Block"  AS "BAIRRO",
		OCRD."ZipCode"  AS "CEP",
		"Phone1"  AS "TELEFONE",
		''  AS "FAX",
		"Cellular"  AS "CELULAR",
		"E_Mail"  AS "EMAIL",
		"Notes" AS "OBS",
		(SELECT cpfCnpj FROM BpCpfCnpj t 
		WHERE 
			OCRD."CardCode" = t."CardCode" 
			AND (SELECT count(1) FROM BpCpfCnpj t WHERE OCRD."CardCode" = t."CardCode") <= 1) AS "CNPJCPF",
		(SELECT iestadual FROM BpCpfCnpj t 
		WHERE 
			OCRD."CardCode" = t."CardCode" 
			AND (SELECT count(1) FROM BpCpfCnpj t WHERE OCRD."CardCode" = t."CardCode") <= 1) AS "IERG",
		CASE WHEN "U_Rov_Data_Nascimento" = '' THEN ' ' ELSE "U_Rov_Data_Nascimento" END   AS "DATANASCIMENTO",
		OCRD."City" AS "CIDADE",
		CRD1."State" AS "UF",
		TO_NVARCHAR(CRD1."Building") AS "COMPLEMENTO", 
		(SELECT IFNULL(MAX(al."Name"),'Sem Regiao') FROM "@ARO_LOCAIS" al WHERE AL."Code" = CRD1."U_Localidade") AS "REGIAO",
		'' AS "ATIVIDADE",
		'' AS "EXTRA1",
		'' AS "EXTRA2",
		'' AS "EXTRA3",
		"E_Mail"  AS "EMAILNFE",
		''  AS "OBSFINANCEIRA",
		'' AS "CLIENTE_TIPO"
	FROM
		OCRD
		LEFT JOIN CRD1 on(CRD1."AdresType" = 'S' AND CRD1."CardCode" = OCRD."CardCode")
		LEFT JOIN CRD2 ON (OCRD."CardCode" = CRD2."CardCode" AND CRD2."LineNum" = 0)
	WHERE OCRD."CardType" = 'C' AND exists(SELECT 1 FROM CRD8 WHERE OCRD."CardCode" = CRD8."CardCode" AND CRD8."BPLId" in(SELECT IDEMPRESAERP FROM EMPRESA))
	GROUP BY
		OCRD."CardCode",
		"CardName",
		"CardName",
		OCRD."Address",
		"Number",
		OCRD."Block",
		OCRD."ZipCode",
		"Phone1",
		"Cellular",
		"E_Mail",
		CASE WHEN "U_Rov_Data_Nascimento" = '' THEN ' ' ELSE "U_Rov_Data_Nascimento" END,
		CRD2."PymCode",
		"Notes",
		OCRD."City",
		CRD1."State",
		CRD1."U_Localidade",
		TO_NVARCHAR(CRD1."Building"),
		TO_VARCHAR(OCRD."CreateDate", 'YYYY-MM-DD HH:MM:SS'),
		TO_VARCHAR("UpdateDate", 'YYYY-MM-DD HH:MM:SS');
		"IDCLIENTEERP" AS "IDCLIENTEERP",
		"NOME"  AS "NOME",
		"RSOCIAL"  AS "RSOCIAL",
		"ENDERECO"  AS "ENDERECO",
		"NUMERO"  AS "NUMERO",
		"BAIRRO"  AS "BAIRRO",
		"CEP"  AS "CEP",
		"TELEFONE"  AS "TELEFONE",
		'FAX'  AS "FAX",
		"CELULAR"  AS "CELULAR",
		"EMAIL"  AS "EMAIL",
		"OBSCADASTRAL" AS "OBS",
		"DESCONTOMAXIMO" AS "MAXDESCONTOPEDIDO",
		"CNPJCPF" AS "CNPJCPF",
		"IERG" AS "IERG",
		"DATANASCIMENTO"   AS "DATANASCIMENTO",
		null AS "CIDADE",
		null AS "UF",
		null AS "COMPLEMENTO", 
		"IDREGIAOERP" AS "REGIAO",
		"IDATIVIDADEERP" AS "ATIVIDADE",
		'' AS "EXTRA1",
		'' AS "EXTRA2",
		'' AS "EXTRA3",
		"EMAIL"  AS "EMAILNFE",
		"OBSFINANCEIRA"  AS "OBSFINANCEIRA",
		"TIPOCLIENTE" AS "CLIENTE_TIPO"
	FROM
		CLIENTE
		
	

