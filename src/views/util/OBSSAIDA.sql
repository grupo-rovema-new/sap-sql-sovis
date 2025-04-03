CREATE OR REPLACE VIEW OBSSAIDA AS
SELECT 
DISTINCT 
    CASE
        WHEN T1."DocEntry" > 0 THEN
            TRIM(LTRIM(
                IFNULL(TO_VARCHAR(T0."Header"), '') || 
                IFNULL(TO_VARCHAR(T0."Footer"), '') || 
                CHAR(10) ||  
                'Vendedor: ' || 
                CASE 
                    WHEN T2."SlpCode" = -1 THEN ''
                    ELSE IFNULL(T2."SlpName", '')
                END
            )) 
    END AS OBS,
    T0."DocEntry",
    T0."ObjType"
FROM OINV T0
LEFT JOIN INV1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN OSLP T2 ON T0."SlpCode" = T2."SlpCode";