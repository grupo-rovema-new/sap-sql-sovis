

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
	fncRemove_acentuacao("Block") AS "BAIRRO",
	fncRemove_Acentuacao("Building").resultado AS "COMPLEMENTO",
	fncRemove_Acentuacao(SUBSTRING("ZipCode",0,10))  AS "CEP",
	fncRemove_Acentuacao("U_TX_IE") AS "IERG",
	'' AS "CNPJCPF",
	'' AS "TELEFONE",
	'' AS "FAX",
	'' AS "CELULAR",
	'' AS "LATITUDE",
	'' AS "LONGITUDE",
	'' AS "PRECISAO"
FROM CRD1
INNER JOIN cliente ON cliente.IDCLIENTEERP = CRD1."CardCode"
INNER JOIN cidade ON cidade.IDCIDADEERP = CRD1."County"
WHERE fncRemove_Acentuacao("Address") = UPPER("Address");