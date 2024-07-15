CREATE OR REPLACE VIEW QUANTIDADETOTALOINM AS
WITH NotaFiscal AS (
    SELECT 
        T0."TransNum",
    	T0."TransType",
    	T0.BASE_REF,
    	CASE 
        WHEN t0."TransType" = 15 THEN T9."Serial"
        WHEN t0."TransType" = 14 THEN T2."Serial"
        WHEN t0."TransType" = 13 THEN T1."Serial"
        WHEN t0."TransType" = 16 THEN T10."Serial"
        WHEN t0."TransType" = 18 THEN T11."Serial"
        WHEN t0."TransType" = 19 THEN T12."Serial"
        WHEN t0."TransType" = 20 THEN T13."Serial"
        WHEN t0."TransType" = 21 THEN T14."Serial"
        WHEN t0."TransType" = 59 THEN T15."Serial"
        WHEN t0."TransType" = 60 THEN T16."Serial"
        WHEN t0."TransType" = 67 THEN T17."U_TX_NDfe"
        WHEN t0."TransType" = 202 THEN T18."Serial"
        WHEN t0."TransType" = 162 THEN T19."Serial"
    END AS "NotaFiscal",
    	CASE 
        WHEN t0."TransType" = 15 THEN T9.CANCELED
        WHEN t0."TransType" = 14 THEN T2.CANCELED
        WHEN t0."TransType" = 13 THEN T1.CANCELED
        WHEN t0."TransType" = 16 THEN T10.CANCELED
        WHEN t0."TransType" = 18 THEN T11.CANCELED
        WHEN t0."TransType" = 19 THEN T12.CANCELED
        WHEN t0."TransType" = 20 THEN T13.CANCELED
        WHEN t0."TransType" = 21 THEN T14.CANCELED
        WHEN t0."TransType" = 59 THEN T15.CANCELED
        WHEN t0."TransType" = 60 THEN T16.CANCELED
        WHEN t0."TransType" = 67 THEN T17.CANCELED
        WHEN t0."TransType" = 202 THEN T18."Status"
    END AS "Cancelado"
    FROM 
    OINM T0
	LEFT JOIN 
	    IBT1 T5 ON T5."BaseNum" = T0.BASE_REF 
	             AND T5."ItemCode" = T0."ItemCode" 
	             AND T5."BaseType" = T0."TransType" 
	             AND T5."WhsCode" = T0."Warehouse" 
	             AND T0."DocLineNum" = T5."BaseLinNum" 
	LEFT JOIN 
	    OBTN T6 ON T6."ItemCode" = T5."ItemCode" 
	             AND T6."DistNumber" = T5."BatchNum"
	LEFT JOIN OINV T1 ON T0."CreatedBy" = T1."DocEntry" AND T0."TransType" = T1."ObjType"
    LEFT JOIN ORIN T2 ON T0."CreatedBy" = T2."DocEntry" AND T0."TransType" = T2."ObjType"
    LEFT JOIN ODLN T9 ON T0."CreatedBy" = T9."DocEntry" AND T0."TransType" = T9."ObjType"
	LEFT JOIN ORDN T10 ON T0."CreatedBy" = T10."DocEntry" AND T0."TransType" = T10."ObjType"
    LEFT JOIN OPCH T11 ON T0."CreatedBy" = T11."DocEntry" AND T0."TransType" = T11."ObjType"
    LEFT JOIN ORPC T12 ON T0."CreatedBy" = T12."DocEntry" AND T0."TransType" = T12."ObjType"
    LEFT JOIN OPDN T13 ON T0."CreatedBy" = T13."DocEntry" AND T0."TransType" = T13."ObjType"
    LEFT JOIN ORPD T14 ON T0."CreatedBy" = T14."DocEntry" AND T0."TransType" = T14."ObjType"
    LEFT JOIN OIGN T15 ON T0."CreatedBy" = T15."DocEntry" AND T0."TransType" = T15."ObjType"
    LEFT JOIN OIGE T16 ON T0."CreatedBy" = T16."DocEntry" AND T0."TransType" = T16."ObjType"
    LEFT JOIN OWTR T17 ON T0."CreatedBy" = T17."DocEntry" AND T0."TransType" = T17."ObjType"
    LEFT JOIN OWOR T18 ON T0."CreatedBy" = T18."DocEntry" AND T0."TransType" = T18."ObjType"
    LEFT JOIN OMRV T19 ON T0."CreatedBy" = T19."DocEntry" AND T0."TransType" = T19."ObjType"
),
Preco AS (
	    SELECT
			  T0."TransNum",
			  T0.BASE_REF, 
			  T0."TransType",
			  T0."ItemCode",
			  CASE 
			        WHEN T0."TransType" IN (162, 202) THEN T0."CalcPrice"
			        ELSE (T0."TransValue" / NULLIF(CASE 
			                                            WHEN T0."InQty" > 0 THEN T0."InQty" 
			                                            ELSE T0."OutQty" * -1 
			                                       END, 0))
    	END AS "Preco"
		FROM OINM T0
		LEFT JOIN IBT1 T5 ON T5."BaseNum" = T0.BASE_REF
		                  AND T5."ItemCode" = T0."ItemCode"
		                  AND T5."BaseType" = T0."TransType"
		                  AND T5."WhsCode" = T0."Warehouse"
		                  AND T0."DocLineNum" = T5."BaseLinNum"
		LEFT JOIN OBTN T6 ON T6."ItemCode" = T5."ItemCode"
		                  AND T6."DistNumber" = T5."BatchNum"
),
Quantidade AS (
	    SELECT
			  T0."TransNum", 
			  T0."TransType",
			  T0.BASE_REF,
			  T0."ItemCode",
			  T5."BatchNum",
			  T6."ExpDate",
			  CASE
				    WHEN T0."TransType" IN (162, 202) THEN T0."InQty"
				    WHEN T5."Quantity" IS NULL AND T0."InQty" > 0 THEN T0."InQty"
				    WHEN T5."Quantity" IS NULL AND T0."OutQty" > 0 THEN -T0."OutQty"
				    ELSE COALESCE(NULLIF(CASE
				        WHEN T0."InQty" > 0 THEN T5."Quantity"
				        ELSE T5."Quantity" * -1
				      END, 0), T0."InQty", T0."OutQty" * -1)
  			 END AS "Quantidade"
		FROM OINM T0
		LEFT JOIN IBT1 T5 ON T5."BaseNum" = T0.BASE_REF
		                  AND T5."ItemCode" = T0."ItemCode"
		                  AND T5."BaseType" = T0."TransType"
		                  AND T5."WhsCode" = T0."Warehouse"
		                  AND T0."DocLineNum" = T5."BaseLinNum"
		LEFT JOIN OBTN T6 ON T6."ItemCode" = T5."ItemCode"
		                  AND T6."DistNumber" = T5."BatchNum"
)
SELECT DISTINCT 
    T0."TransNum",
    T0."TransType",
    T0."DocLineNum",
    T0."ItemCode",
    qtde."BatchNum",
    T0."DocDate" AS "DatLanc",
    T0."CreateDate" AS "DatSist",
    qtde."ExpDate",
    T0."Warehouse",
    nf."Cancelado",
    pr."Preco",
    qtde."Quantidade",
    pr."Preco"*qtde."Quantidade" AS "ValorTotal",
    nf."NotaFiscal"
FROM 
    OINM T0
LEFT JOIN preco pr ON t0."TransNum" = pr."TransNum" AND t0."ItemCode" = pr."ItemCode"
LEFT JOIN quantidade qtde ON t0."TransNum" = qtde."TransNum" AND t0."ItemCode" = qtde."ItemCode"
LEFT JOIN  NotaFiscal nf ON t0."TransNum" = nf."TransNum";
