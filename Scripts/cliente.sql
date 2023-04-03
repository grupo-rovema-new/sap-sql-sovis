CREATE OR REPLACE VIEW CLIENTE AS 
	SELECT
		OCRD."CardCode" AS "IDCLIENTEERP",
		0 AS "IDCIDADEERP",
		"validFor" AS "IDSITUACAOERP",
		0 AS "IDREGIAOERP",
		0 AS "IDATIVIDADEERP",
		0 AS "IDRAMOERP",
		"CardName"  AS "NOME",
		"CardName"  AS "RSOCIAL",
		"Address"  AS "ENDERECO",
		"Number"  AS "NUMERO",
		"Block"  AS "BAIRRO",
		"ZipCode"  AS "CEP",
		'' AS "IERG",
		'' AS "CNPJCPF",
		"Phone1"  AS "TELEFONE",
		"Fax"  AS "FAX",
		"Cellular"  AS "CELULAR",
		"E_Mail"  AS "EMAIL",
		"E_Mail"  AS "EMAILNFE",
		CASE WHEN "U_Rov_Data_Nascimento" = '' THEN ' ' ELSE "U_Rov_Data_Nascimento" END   AS "DATANASCIMENTO",
		"Free_Text"  AS "OBSCADASTRAL",
		'' AS "OBSFINANCEIRA",
		"ListNum"  AS "IDTABPRECOERP",
		"ListNum" AS "IDTABPRECOTROCAERP",
		"ListNum" AS "IDTABPRECOBONIFICACAOERP",
		CRD2."PymCode"  AS "IDFORMAPAGTOERP",
		"PaymBlock"  AS "IDPRAZOPAGTOERP",
		0 AS "COEFTABPRECO",
		0 AS "DESCONTOMAXIMO",
		'' AS "EXTRA1",
		'' AS "EXTRA2",
		'' AS "EXTRA3",
		TO_VARCHAR("CreateDate", 'YYYY-MM-DD HH:MM:SS')  AS "DATAHORA",
		1 AS "TIPOCONSUMIDOR",
		0 AS "CONTRIBUINTEICMS",
		0 AS "FARMPOPULAR",
		0 AS "CODOPERACAOCOM",
		0 AS "COMPLEMENTO",
		0 AS "IDENDERECOENTREGAPADRAO",
		0 AS "IDENDERECOCOBRANCAPADRAO",
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
		LEFT JOIN CRD2 ON (OCRD."CardCode" = CRD2."CardCode" AND CRD2."LineNum" = 0)
		LEFT JOIN CRD8 ON OCRD."CardCode" = CRD8."CardCode"
	WHERE OCRD."CardType" = 'C' AND CRD8."BPLId" in(2,4,11)
		
-- esse left join vai ajudar a conectar o cliente com a filial		
-- LEFT JOIN CRD8 ON (OCRD."CardCode" = CRD8."CardCode" AND CRD8."DisabledBP" = 'N');	
-- A ideia para ativo e desativo sera nas colunas frozenFor
	
	
