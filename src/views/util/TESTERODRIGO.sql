CREATE VIEW	SBOGRUPOROVEMA.MOVESTOQUE AS
SELECT
    T0."TransNum" AS "Nº Transação",
    T0."TransType" AS "Tipo de documento",
    T0."DocDate" AS "Data de lançamento",
    T0."ItemCode" AS "Código do item",
    T0."Dscription" AS "Nome do item",
    T0."OutQty" AS "Quantidade que saiu",
    T0."InQty" AS "Quantidade que entrou",
    CASE
        WHEN T0."InQty" > 0 THEN COALESCE(T5."Quantity", T0."InQty")
        WHEN T0."OutQty" > 0 THEN COALESCE(T5."Quantity", T0."OutQty" * -1)
    END AS "Quantidade",
    T0."Balance" AS "Vlr Acumulado",
    CASE 
        WHEN T0."JrnlMemo" LIKE '%Cancelamento%' THEN 'Cancelado'
    END AS "Status2",
    (SELECT SUM("InQty" - "OutQty") FROM OINM WHERE T0."ItemCode" = "ItemCode" AND T0."Warehouse" = "Warehouse" AND "DocDate" < '2024-01-22') AS "QtdeIni",
    (SELECT SUM("TransValue") FROM OINM WHERE T0."ItemCode" = "ItemCode" AND T0."Warehouse" = "Warehouse" AND "DocDate" < '2024-01-22') AS "VlrIni",
    T0."CalcPrice" AS "Preço",
    (T0."TransValue" / CASE
        WHEN T0."InQty" > 0 THEN T0."InQty"
        WHEN T0."OutQty" > 0 THEN (T0."OutQty" * -1)
    END) AS "Preço2",
    CASE
        WHEN T0."InQty" > 0 THEN T0."InQty"
        WHEN T0."OutQty" > 0 THEN (T0."OutQty" * -1)
    END AS "Qtde",
    T0."Warehouse" AS "Depósito",
    T0."TransValue" AS "Valor da transação",
    T0."OpenValue" AS "Valor em aberto",
    T1."InvntryUom" AS "UM",
    T1."ItmsGrpCod" AS "Código do grupo de item",
    T4."ItmsGrpNam" AS "Nome do grupo de item",
    T2."WhsName" AS "Nome do Depósito",
    T2."BPLid" AS "CodFilial",
    T3."BPLName" AS "Filial",
    T0."Comments" AS "Observação",
    T0."JrnlMemo" AS "Status",
    T6."ExpDate" AS "Data de Vencimento",
    T0.BASE_REF AS "DocNum",
    T5."BatchNum" AS "Lote"
FROM
    OINM T0
    INNER JOIN OITM T1 ON T0."ItemCode" = T1."ItemCode"
    INNER JOIN OWHS T2 ON T0."Warehouse" = T2."WhsCode"
    INNER JOIN OBPL T3 ON T2."BPLid" = T3."BPLId"
    INNER JOIN OITB T4 ON T1."ItmsGrpCod" = T4."ItmsGrpCod"
    LEFT JOIN IBT1 T5 ON T5."BaseNum" = T0.BASE_REF AND T5."ItemCode" = T0."ItemCode" AND T5."BaseType" = T0."TransType" AND t5."WhsCode" = t0."Warehouse"
    LEFT JOIN OBTN T6 ON T6."ItemCode" = T5."ItemCode" AND T6."DistNumber" = T5."BatchNum"
WHERE
    T0."DocDate" BETWEEN '2024-01-22' AND '2024-02-01';