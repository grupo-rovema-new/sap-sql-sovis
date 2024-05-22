CREATE OR REPLACE VIEW FORNECEDOR AS
SELECT 
    T0."CardCode" AS "DFORNECEDORERP",
    SUBSTRING(T0."CardName",1,50)  AS "NOME",
    SUBSTRING(T0."CardName",1,50) AS "RSOCIAL",
    T1."Address" AS "ENDERECO",
    T1."Block" AS "BAIRRO",
    T1."City" AS "CIDADE",
    T1."State" AS "ESTADO",
    SUBSTRING(T0."Phone1",1,20) AS "TELEFONE",
    '' AS "CONTATO",
    T0."IntrntSite" AS "SITE",
    T0."E_Mail" AS "EMAIL",
    SUBSTRING(T0."Free_Text",1,255) AS "OBS"
FROM
    OCRD T0 
    INNER JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode"
WHERE 
    T0."CardType" = 'S' 
    and T1."AdresType" = 'B';