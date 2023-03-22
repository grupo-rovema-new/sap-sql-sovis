CREATE OR REPLACE VIEW FORNECEDOR AS 
SELECT 
T0."CardCode" AS "DFORNECEDORERP",
 T0."CardName" AS "NOME",
 T0."CardName" AS "RSOCIAL",
 T1."Address" AS "ENDERECO",
 T1."Block" AS "BAIRRO",
 T1."City" AS "CIDADE",
 T1."State" AS "ESTADO",
 T0."Phone1" AS "TELEFONE",
 '' AS "CONTATO",
 T0."IntrntSite" AS "SITE",
 T0."E_Mail" AS "EMAIL",
 T0."Free_Text" AS "OBS"
 FROM OCRD T0 
 INNER JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode"
 WHERE T0."CardType" = 'S' and T1."AdresType" = 'B'