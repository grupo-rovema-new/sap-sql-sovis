CREATE OR REPLACE VIEW SBOGRUPOROVEMA.NFS_COMISSOESTITULOS AS
SELECT --Nota Fiscal de Saída
T0."DocEntry",
t0."DocNum",
T11."U_regressiva",
T11."U_porcentagem",
COALESCE (T5."BaseLine",0) AS "BaseLine",
CASE 
    WHEN (COALESCE(T11."U_regressiva", '') = '' OR T11."U_regressiva" = '0') THEN
        CASE 
            WHEN T5."DiscPrcnt" BETWEEN 1.000000 AND 1.999999 THEN 11
            WHEN T5."DiscPrcnt" BETWEEN 2.000000 AND 2.999999 THEN 10
            WHEN T5."DiscPrcnt" BETWEEN 3.000000 AND 3.999999 THEN 9
            WHEN T5."DiscPrcnt" BETWEEN 4.000000 AND 4.999999 THEN 8
            WHEN T5."DiscPrcnt" BETWEEN 5.000000 AND 5.999999 THEN 7
            WHEN T5."DiscPrcnt" BETWEEN 6.000000 AND 6.499999 THEN 6.2
            WHEN T5."DiscPrcnt" BETWEEN 6.500000 AND 6.999999 THEN 6
            WHEN T5."DiscPrcnt" BETWEEN 7.000000 AND 7.499999 THEN 5.8
            WHEN T5."DiscPrcnt" BETWEEN 7.500000 AND 7.999999 THEN 5.4
            WHEN T5."DiscPrcnt" BETWEEN 8.000000 AND 8.499999 THEN 5
            WHEN T5."DiscPrcnt" BETWEEN 8.500000 AND 8.999999 THEN 4.6
            WHEN T5."DiscPrcnt" BETWEEN 9.000000 AND 9.499999 THEN 4.2
            WHEN T5."DiscPrcnt" BETWEEN 9.500000 AND 9.999999 THEN 4.0
            WHEN T5."DiscPrcnt" BETWEEN 10.000000 AND 10.499999 THEN 3.8
            WHEN T5."DiscPrcnt" BETWEEN 10.500000 AND 10.999999 THEN 3.6
            WHEN T5."DiscPrcnt" BETWEEN 11.000000 AND 11.499999 THEN 3.4
            WHEN T5."DiscPrcnt" BETWEEN 11.500000 AND 11.999999 THEN 3.2
            WHEN T5."DiscPrcnt" = 12.000000 THEN 3
            WHEN T5."DiscPrcnt" = 15.000000 THEN 0
            ELSE 12
        END
    WHEN T11."U_regressiva" = '1' THEN T11."U_porcentagem"
    ELSE NULL
END AS "PorcComissao"
FROM
		"OINV" T0
LEFT JOIN "INV1" T5 ON
		T0."DocEntry" = T5."DocEntry"
LEFT JOIN "OPLN" T10 ON
		T5."U_idTabela" = T10."ListNum"
LEFT JOIN "@COMISSAO" T11 ON
		T10."U_tipoComissao" = T11."Code"

UNION

SELECT --Fatura de Adiantamento de clientes
T0."DocEntry",
t0."DocNum",
T11."U_regressiva",
T11."U_porcentagem",
COALESCE (T5."BaseLine",0) AS "BaseLine",
CASE 
    WHEN (COALESCE(T11."U_regressiva", '') = '' OR T11."U_regressiva" = '0') THEN
        CASE 
            WHEN T5."DiscPrcnt" BETWEEN 1.000000 AND 1.999999 THEN 11
            WHEN T5."DiscPrcnt" BETWEEN 2.000000 AND 2.999999 THEN 10
            WHEN T5."DiscPrcnt" BETWEEN 3.000000 AND 3.999999 THEN 9
            WHEN T5."DiscPrcnt" BETWEEN 4.000000 AND 4.999999 THEN 8
            WHEN T5."DiscPrcnt" BETWEEN 5.000000 AND 5.999999 THEN 7
            WHEN T5."DiscPrcnt" BETWEEN 6.000000 AND 6.499999 THEN 6.2
            WHEN T5."DiscPrcnt" BETWEEN 6.500000 AND 6.999999 THEN 6
            WHEN T5."DiscPrcnt" BETWEEN 7.000000 AND 7.499999 THEN 5.8
            WHEN T5."DiscPrcnt" BETWEEN 7.500000 AND 7.999999 THEN 5.4
            WHEN T5."DiscPrcnt" BETWEEN 8.000000 AND 8.499999 THEN 5
            WHEN T5."DiscPrcnt" BETWEEN 8.500000 AND 8.999999 THEN 4.6
            WHEN T5."DiscPrcnt" BETWEEN 9.000000 AND 9.499999 THEN 4.2
            WHEN T5."DiscPrcnt" BETWEEN 9.500000 AND 9.999999 THEN 4.0
            WHEN T5."DiscPrcnt" BETWEEN 10.000000 AND 10.499999 THEN 3.8
            WHEN T5."DiscPrcnt" BETWEEN 10.500000 AND 10.999999 THEN 3.6
            WHEN T5."DiscPrcnt" BETWEEN 11.000000 AND 11.499999 THEN 3.4
            WHEN T5."DiscPrcnt" BETWEEN 11.500000 AND 11.999999 THEN 3.2
            WHEN T5."DiscPrcnt" = 12.000000 THEN 3
            WHEN T5."DiscPrcnt" = 15.000000 THEN 0
            ELSE 12
        END
    WHEN T11."U_regressiva" = '1' THEN T11."U_porcentagem"
    ELSE NULL
END AS "PorcComissao"
FROM
		"ODPI" T0
LEFT JOIN "DPI1" T5 ON
		T0."DocEntry" = T5."DocEntry"
LEFT JOIN "OPLN" T10 ON
		T5."U_idTabela" = T10."ListNum"
LEFT JOIN "@COMISSAO" T11 ON
		T10."U_tipoComissao" = T11."Code";
		