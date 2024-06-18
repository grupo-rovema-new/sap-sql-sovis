CREATE OR REPLACE VIEW QUANTIDADETOTALOINM AS
SELECT 
    T0."TransNum",
    T0."TransType",
    T0."DocLineNum",
    T0."ItemCode",
    T5."BatchNum",
    T0."DocDate" AS "DatLanc",
    T0."CreateDate" AS "DatSist",
    T6."ExpDate",
    T0."Warehouse",
    CASE 
        WHEN T0."TransType" IN (15, 14, 13, 16, 18, 19, 20, 21, 59, 60, 67) THEN 
            CASE T0."TransType" 
                WHEN 67 THEN (SELECT "Status" FROM OWOR WHERE "DocEntry" = T0."CreatedBy" AND "ObjType" = T0."TransType")
                ELSE (SELECT "CANCELED" FROM (
                            SELECT "CANCELED", ROW_NUMBER() OVER (ORDER BY "DocEntry" DESC) AS rn
                            FROM (
                                SELECT "CANCELED", "DocEntry", "ObjType" FROM OINV WHERE "DocEntry" = T0."CreatedBy" AND "ObjType" = T0."TransType"
                                UNION ALL
                                SELECT "CANCELED", "DocEntry", "ObjType" FROM ORIN WHERE "DocEntry" = T0."CreatedBy" AND "ObjType" = T0."TransType"
                                UNION ALL
                                SELECT "CANCELED", "DocEntry", "ObjType" FROM ODLN WHERE "DocEntry" = T0."CreatedBy" AND "ObjType" = T0."TransType"
                                UNION ALL
                                SELECT "CANCELED", "DocEntry", "ObjType" FROM ORDN WHERE "DocEntry" = T0."CreatedBy" AND "ObjType" = T0."TransType"
                                UNION ALL
                                SELECT "CANCELED", "DocEntry", "ObjType" FROM OPCH WHERE "DocEntry" = T0."CreatedBy" AND "ObjType" = T0."TransType"
                                UNION ALL
                                SELECT "CANCELED", "DocEntry", "ObjType" FROM ORPC WHERE "DocEntry" = T0."CreatedBy" AND "ObjType" = T0."TransType"
                                UNION ALL
                                SELECT "CANCELED", "DocEntry", "ObjType" FROM OPDN WHERE "DocEntry" = T0."CreatedBy" AND "ObjType" = T0."TransType"
                                UNION ALL
                                SELECT "CANCELED", "DocEntry", "ObjType" FROM ORPD WHERE "DocEntry" = T0."CreatedBy" AND "ObjType" = T0."TransType"
                                UNION ALL
                                SELECT "CANCELED", "DocEntry", "ObjType" FROM OIGN WHERE "DocEntry" = T0."CreatedBy" AND "ObjType" = T0."TransType"
                                UNION ALL
                                SELECT "CANCELED", "DocEntry", "ObjType" FROM OIGE WHERE "DocEntry" = T0."CreatedBy" AND "ObjType" = T0."TransType"
                                UNION ALL
                                SELECT "CANCELED", "DocEntry", NULL AS "ObjType" FROM OWTR WHERE "DocEntry" = T0."CreatedBy"
                                UNION ALL
                                SELECT NULL AS "CANCELED", "DocEntry", NULL AS "ObjType" FROM OWOR WHERE "DocEntry" = T0."CreatedBy"
                            ) AS CANCEL
                        ) AS T20 WHERE rn = 1)
            END
    END AS "Cancelado",
    CASE 
        WHEN T0."TransType" IN (162, 202) THEN T0."CalcPrice"
        ELSE (T0."TransValue" / NULLIF(CASE 
                                            WHEN T0."InQty" > 0 THEN T0."InQty" 
                                            ELSE T0."OutQty" * -1 
                                         END, 0))
    END AS "Preco",
    CASE 
        WHEN T0."TransType" IN (162, 202) THEN T0."InQty"
        ELSE COALESCE(NULLIF(CASE 
                                WHEN T0."InQty" > 0 THEN T5."Quantity"
                                ELSE T5."Quantity" * -1
                             END, 0), T0."InQty", T0."OutQty" * -1)
    END AS "Quantidade",
    CASE 
        WHEN T0."TransType" IN (162, 202) THEN T0."TransValue"
        ELSE (T0."TransValue" / NULLIF(CASE 
                                            WHEN T0."InQty" > 0 THEN T0."InQty" 
                                            ELSE T0."OutQty" * -1 
                                         END, 0) * COALESCE(NULLIF(CASE 
                                                                            WHEN T0."InQty" > 0 THEN T5."Quantity"
                                                                            ELSE T5."Quantity" * -1
                                                                        END, 0), T0."InQty", T0."OutQty" * -1))
    END AS "ValorTotal"
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