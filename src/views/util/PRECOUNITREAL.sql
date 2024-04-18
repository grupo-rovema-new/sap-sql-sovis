CREATE OR REPLACE VIEW "PRECOUNITREAL" AS 
SELECT T0."TransNum", 
	   (T0."TransValue"/(CASE WHEN T0."InQty" > 0 THEN T0."InQty" WHEN T0."OutQty" > 0 THEN (T0."OutQty"*-1)END)) AS "Preco",
	   CASE
		WHEN T0."InQty" > 0 THEN 
							CASE 
								WHEN T5."Quantity" IS NULL THEN T0."InQty"
								ELSE T5."Quantity"
							END							
		WHEN T0."OutQty" > 0 THEN
							CASE 
								WHEN T5."Quantity" IS NULL THEN (T0."OutQty"*-1)
                ELSE (T5."Quantity"*-1)
							END							
		END AS "Quantidade",
ROUND(((T0."TransValue"/(CASE WHEN T0."InQty" > 0 THEN T0."InQty" WHEN T0."OutQty" > 0 THEN (T0."OutQty"*-1)END))*(CASE
		WHEN T0."InQty" > 0 THEN 
							CASE 
								WHEN T5."Quantity" IS NULL THEN T0."InQty"
								ELSE T5."Quantity"
							END							
		WHEN T0."OutQty" > 0 THEN
							CASE 
								WHEN T5."Quantity" IS NULL THEN (T0."OutQty"*-1)
                ELSE (T5."Quantity"*-1)
							END							
		END)),2) AS "ValorTotal",
		CASE WHEN SIGN(CASE
		WHEN T0."InQty" > 0 THEN 
							CASE 
								WHEN T5."Quantity" IS NULL THEN T0."InQty"
								ELSE T5."Quantity"
							END							
		WHEN T0."OutQty" > 0 THEN
							CASE 
								WHEN T5."Quantity" IS NULL THEN (T0."OutQty"*-1)
                ELSE (T5."Quantity"*-1)
							END							
		END ) = 1 THEN 'E'
			WHEN SIGN(CASE
		WHEN T0."InQty" > 0 THEN 
							CASE 
								WHEN T5."Quantity" IS NULL THEN T0."InQty"
								ELSE T5."Quantity"
							END							
		WHEN T0."OutQty" > 0 THEN
							CASE 
								WHEN T5."Quantity" IS NULL THEN (T0."OutQty"*-1)
                ELSE (T5."Quantity"*-1)
							END							
		END ) = -1 THEN 'S' END AS "Movimento"
FROM oinm t0
LEFT JOIN IBT1 T5 ON T5."BaseNum" = T0.BASE_REF AND T5."ItemCode" = T0."ItemCode" AND T5."BaseType" = T0."TransType" AND t5."WhsCode" = t0."Warehouse";
