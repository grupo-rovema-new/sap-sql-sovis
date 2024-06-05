CREATE OR REPLACE VIEW BPCPFCNPJ AS
SELECT DISTINCT 
		CRD7."CardCode",
		CASE 
			WHEN "TaxId4" = '' OR "TaxId4" IS null THEN "TaxId0"
			ELSE "TaxId4"
		END AS cpfCnpj,
		CRD7."TaxId1" AS  iestadual
	FROM CRD7 WHERE (("TaxId4" IS NOT NULL AND "TaxId4" <> '' AND ("TaxId0" IS NULL OR "TaxId0" = '')) or ("TaxId0" IS NOT null AND "TaxId0" <> '' AND ("TaxId4" IS NULL OR "TaxId4" = '')));