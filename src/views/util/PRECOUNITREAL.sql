CREATE OR REPLACE VIEW "PRECOUNITREAL" AS 
SELECT T0."TransNum", 
	   (T0."TransValue"/(CASE WHEN T0."InQty" > 0 THEN T0."InQty" WHEN T0."OutQty" > 0 THEN (T0."OutQty"*-1)END)) AS "Preço" 
FROM oinm t0;
