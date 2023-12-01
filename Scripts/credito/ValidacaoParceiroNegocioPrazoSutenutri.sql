CREATE OR REPLACE VIEW ValidacaoParceiroNegocioPrazoSutenutri AS (
SELECT * FROM 
	(SELECT
		CASE
					WHEN LENGTH(COALESCE("Phone1",'1')) < 2 THEN 'Informe o numero de telefone'
					WHEN LENGTH(COALESCE("U_Rov_Data_Nascimento",'0')) < 10 THEN 'Informe a data de nascimento ou abertura'
					WHEN LENGTH(COALESCE("U_Rov_Nome_Mae",'0')) < 5 AND LENGTH(COALESCE("TaxId4",'0')) > 2 THEN 'Informe o nome da mae'
					WHEN conjuge."U_tipoPessoa" IS NOT NULL AND LENGTH(COALESCE("FirstName",'0')) < 3 THEN 'Informe o nome do conjuge'
					WHEN conjuge."U_tipoPessoa" IS NOT NULL AND LENGTH(COALESCE("LastName",'0')) < 3 THEN 'Informe o ultimo nome do conjuge'
					WHEN conjuge."U_tipoPessoa" IS NOT NULL AND LENGTH(COALESCE("U_TX_IdFiscalAut",'0')) < 5 THEN 'Informe o CPF do conjuge'
					WHEN conjuge."U_tipoPessoa" IS NOT NULL AND LENGTH(COALESCE("BirthDate",'0')) < 5 THEN 'Informe a data de nascimento do conjuge'
					WHEN cobranca."AdresType" IS NULL THEN 'Deve existir um endereço de cobrança'
					WHEN LENGTH(COALESCE(cobranca."AddrType",'0')) < 3 THEN 'Informe o Logradouro do endereço de cobrança'
					WHEN LENGTH(COALESCE(cobranca."County",'0')) < 1 THEN 'Informe a cidade do endereço de cobrança'
					WHEN LENGTH(COALESCE(cobranca."State",'0')) < 1 THEN 'Informe o estado do endereço de cobrança'
					WHEN LENGTH(COALESCE(cobranca."ZipCode",'0')) < 1 THEN 'Informe o CEP do endereço de cobrança'
					WHEN LENGTH(COALESCE(cobranca."StreetNo",'0')) < 1 THEN 'Informe o Numero do endereço de cobrança'
					WHEN LENGTH(COALESCE(pn."E_Mail",'0')) < 5 THEN 'Deve existir um endereço de email'
		END AS MSG,
		pn."CardCode"
	FROM
			OCRD AS pn
			INNER JOIN CRD8 pnf ON (pn."CardCode" = pnf."CardCode" AND pnf."BPLId" IN(2,4,11,17) AND pnf."DisabledBP" = 'N')
			LEFT JOIN  CRD7 pnDoc ON (pn."CardCode" = pnDoc."CardCode" AND (LENGTH(COALESCE("TaxId4",'0')) > 2 OR LENGTH(COALESCE("TaxId0",'0')) > 2 ))
			LEFT JOIN OCPR conjuge ON pn."CardCode" = conjuge."CardCode" AND conjuge."U_tipoPessoa" = 'conjuge'
			LEFT JOIN CRD1 cobranca ON pn."CardCode" = cobranca."CardCode" AND cobranca."AdresType" = 'B'
	WHERE
		pn."CreditLine" > 0
		AND pn."CardType" = 'C'
	UNION
		SELECT * FROM ValidacaoParceiroNegocioSutenutri
	)
WHERE
	LENGTH(MSG) > 2
)
