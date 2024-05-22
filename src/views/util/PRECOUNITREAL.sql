CREATE OR REPLACE VIEW PRECOUNITREAL AS
SELECT T0."TransNum", T0."TransType",T0."DocLineNum",T0."ItemCode",
	   CASE WHEN T0."TransType" = 162 THEN T0."CalcPrice" 
	   		WHEN T0."TransType" = 202 THEN T0."CalcPrice" ELSE  
       (T0."TransValue"/(CASE WHEN T0."InQty" > 0 THEN T0."InQty" WHEN T0."OutQty" > 0 THEN (T0."OutQty"*-1)END)) END AS "Preco"
FROM oinm t0;