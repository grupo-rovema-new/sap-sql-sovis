-- SBOGRUPOROVEMA.OBSENTREGA fonte

/*CREATE VIEW SBOGRUPOROVEMA.OBSENTREGA AS
SELECT
DISTINCT 
CASE
	WHEN (T1."DocEntry" > 0 and T2."BaseEntry" > 0 and T2."BaseType" = 13) THEN
		RTrim(LTrim( IfNull(To_Varchar(T0."Header"),'''') ||  '' || IfNull(To_Varchar(T0."Footer"),'''') ) )  || 
		' \nSaída referente a faturamento efetuado através da Nota Fiscal número ' ||   T3."Serial"
END  AS OBS ,T0."DocEntry",
T0."ObjType" 
FROM ODLN T0
left JOIN DLN1 T2 ON T0."DocEntry" = T2."DocEntry" 
left join INV1 T1 on T2."BaseEntry" = T1."DocEntry"
left join OINV T3 on T3."DocEntry" = T1."DocEntry"; */

CREATE OR REPLACE VIEW OBSENTREGA AS
SELECT DISTINCT
    CASE
        WHEN (T1."DocEntry" > 0 AND T2."BaseEntry" > 0 AND T2."BaseType" = 13) THEN
            RTRIM(LTRIM(
                IFNULL(TO_VARCHAR(T0."Header"), '') || ' ' || 
                IFNULL(TO_VARCHAR(T0."Footer"), '')
            )) || '\nSaída referente a faturamento efetuado através da Nota Fiscal número ' || T3."Serial"
        ELSE
            RTRIM(LTRIM(
                IFNULL(TO_VARCHAR(T0."Header"), '') || ' ' || 
                IFNULL(TO_VARCHAR(T0."Footer"), '') || CHAR(10) ||
                'Vendedor: ' || 
                CASE 
                    WHEN T2."SlpCode" = -1 THEN ''
                    ELSE IFNULL(T4."SlpName", '')
                END
            ))
    END AS OBS,
    T0."DocEntry",
    T0."ObjType"
FROM ODLN T0
LEFT JOIN DLN1 T2 ON T0."DocEntry" = T2."DocEntry"
LEFT JOIN INV1 T1 ON T2."BaseEntry" = T1."DocEntry"
LEFT JOIN OINV T3 ON T3."DocEntry" = T1."DocEntry"
LEFT JOIN OSLP T4 ON T0."SlpCode" = T4."SlpCode";