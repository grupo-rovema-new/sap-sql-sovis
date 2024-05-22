-- SBOGRUPOROVEMA.CLIENTE source

CREATE OR REPLACE VIEW CLIENTE AS
SELECT
		OCRD."CardCode" AS "IDCLIENTEERP",
		MAX(CRD1."County") AS "IDCIDADEERP",
		(SELECT
			CASE
				WHEN idade >= 180 THEN '6m'
				WHEN idade >= 4*30 THEN '4m'
				WHEN idade >= 60 THEN '60d'
				WHEN idade >= 30 THEN '30d'
				WHEN idade < 30 THEN 'dia'
				ELSE 'sh'
			END
		FROM 
			(SELECT 
				DAYS_BETWEEN(MAX("data"),CURRENT_DATE) AS idade
			FROM 
				FATURAMENTO f 
			WHERE 
				"faturado" > 0 AND "CardCode" = OCRD."CardCode"))
		AS "IDSITUACAOERP",
		IFNULL(MAX("U_Localidade"),'-1') AS "IDREGIAOERP",
		0 AS "IDATIVIDADEERP",
		0 AS "IDRAMOERP",
		"CardName"  AS "NOME",
		"CardName"  AS "RSOCIAL",
		OCRD."Address"  AS "ENDERECO",
		"Number"  AS "NUMERO",
		OCRD."Block"  AS "BAIRRO",
		OCRD."ZipCode"  AS "CEP",
		(SELECT iestadual FROM BpCpfCnpj t 
		WHERE 
			OCRD."CardCode" = t."CardCode" 
			AND (SELECT count(1) FROM BpCpfCnpj t WHERE OCRD."CardCode" = t."CardCode") <= 1) AS "IERG",
		(SELECT cpfCnpj FROM BpCpfCnpj t 
		WHERE 
			OCRD."CardCode" = t."CardCode" 
			AND (SELECT count(1) FROM BpCpfCnpj t WHERE OCRD."CardCode" = t."CardCode") <= 1) AS "CNPJCPF",
		"Phone1"  AS "TELEFONE",
		''  AS "FAX",
		"Cellular"  AS "CELULAR",
		"E_Mail"  AS "EMAIL",
		"E_Mail"  AS "EMAILNFE",
		CASE WHEN "U_Rov_Data_Nascimento" = '' THEN ' ' ELSE "U_Rov_Data_Nascimento" END   AS "DATANASCIMENTO",
		''  AS "OBSCADASTRAL",
		'' AS "OBSFINANCEIRA",
		4  AS "IDTABPRECOERP",
		4 AS "IDTABPRECOTROCAERP",
		4 AS "IDTABPRECOBONIFICACAOERP",
		CRD2."PymCode"  AS "IDFORMAPAGTOERP",
		-1  AS "IDPRAZOPAGTOERP",
		0 AS "COEFTABPRECO",
		0 AS "DESCONTOMAXIMO",
		'' AS "EXTRA1",
		'' AS "EXTRA2",
		'' AS "EXTRA3",
		TO_VARCHAR(OCRD."CreateDate", 'YYYY-MM-DD HH:MM:SS')  AS "DATAHORA",
		1 AS "TIPOCONSUMIDOR",
		0 AS "CONTRIBUINTEICMS",
		0 AS "FARMPOPULAR",
		0 AS "CODOPERACAOCOM",
		0 AS "COMPLEMENTO",
		(SELECT max("CardCode"||'-'||"AdresType"||'-'||"Address") FROM CRD1 WHERE "CardCode" = OCRD."CardCode" AND "AdresType" = 'S' ) AS "IDENDERECOENTREGAPADRAO",
		(SELECT max("CardCode"||'-'||"AdresType"||'-'||"Address") FROM CRD1 WHERE "CardCode" = OCRD."CardCode" AND "AdresType" = 'B' ) AS "IDENDERECOCOBRANCAPADRAO",
		'N' AS "RECEBIMENTOPARCIAL",
		0 AS "IDMATRIZ",
		0 AS "IGNORAREGRAFLEX",
		0 AS "LATITUDE",
		0 AS "LONGITUDE",
		0 AS "PDOT",
		0 AS "VALORMINIMOFOB",
		0 AS "VALORMINIMOCIF",
		'' AS "DATAULTIMAVENDA",
		TO_VARCHAR("UpdateDate", 'YYYY-MM-DD HH:MM:SS')  AS "DATAHORAATUALIZACAO",
		0 AS "CONTRIBUINTE",
		0 AS "ESTRANGEIRO",
		0 AS "TIPOCLIENTE",
		0 AS "PRAZOENTREGA",
		0 AS "FREQUENCIACOMPRA",
		0 AS "ESTOQUESEGURANCA",
		0 AS "IDTIPOPEDIDOERP",
		0 AS "IDTRANSPORTADORAERP",
		0 AS "IDCLI_GRUPOECONOMICOERP"
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
	TO_VARCHAR(OCRD."CreateDate", 'YYYY-MM-DD HH:MM:SS'),
	TO_VARCHAR("UpdateDate", 'YYYY-MM-DD HH:MM:SS');