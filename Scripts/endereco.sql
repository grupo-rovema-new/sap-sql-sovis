CREATE OR REPLACE VIEW  TIPOENDERECO AS
SELECT
	tipo."AdresType" AS "IDTIPOENDERECOERP",
	CASE
		WHEN tipo."AdresType" = 'S' THEN 'ENTREGA'
		WHEN tipo."AdresType" = 'B' THEN 'COBRANCA'
	END AS "DESCRICAO",
	tipo."AdresType" AS "TIPO"
FROM
	CRD1 AS tipo
GROUP BY tipo."AdresType";
	

CREATE OR REPLACE VIEW ENDERECO AS
SELECT 
	"CardCode"||'-'||"AdresType"||'-'||"Address"  AS "IDENDERECOERP",
	"AdresType" AS "IDTIPOENDERECOERP",
	"CardCode" AS "IDCLIENTEERP",
	"County" AS "IDCIDADEERP",
	'' AS "NOME",
	'' AS "RSOCIAL",
	fncRemove_Acentuacao("Street").resultado AS "ENDERECO",
	fncRemove_acentuacao(substring("StreetNo",0,15)).resultado  AS "NUMERO",
	"Block" AS "BAIRRO",
	fncRemove_Acentuacao("Building").resultado AS "COMPLEMENTO",
	SUBSTRING("ZipCode",0,10)  AS "CEP",
	"U_TX_IE" AS "IERG",
	'' AS "CNPJCPF",
	'' AS "TELEFONE",
	'' AS "FAX",
	'' AS "CELULAR",
	'' AS "LATITUDE",
	'' AS "LONGITUDE",
	'' AS "PRECISAO"
FROM CRD1
INNER JOIN cliente ON cliente.IDCLIENTEERP = CRD1."CardCode";







