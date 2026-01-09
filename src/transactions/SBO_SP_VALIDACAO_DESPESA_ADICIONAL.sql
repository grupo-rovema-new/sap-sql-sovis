CREATE OR REPLACE PROCEDURE SBO_SP_VALIDACAO_DESPESA_ADICIONAL

(
	in object_type nvarchar(30), 				-- SBO Object Type
	in transaction_type nchar(1),			-- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
	in num_of_cols_in_key int,
	in list_of_key_cols_tab_del nvarchar(255),
	in list_of_cols_val_tab_del nvarchar(255),
	INOUT error int,
	INOUT error_message nvarchar(200)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
v_frete_sem_imp DECIMAL(15,2);
v_diff DECIMAL(15,2);
notaSemDespesa nvarchar(255);
begin
---------------------------Despesa de importaçao----------------------------------------------------------------
if  :object_type = '69' and (:transaction_type = 'A') THEN
IF EXISTS (
    WITH BASE AS (
    SELECT 
        O."DocEntry",
        O."DocNum"   AS "OrdemOIPF",
        NF."DocEntry" AS "NFDocEntry",
        NF."DocNum"  AS "NotaEntrada",
        O."DocDate"  AS "DataOIPF",
        NF."DocDate" AS "DataEntrada"
    FROM OIPF O
    INNER JOIN IPF1 I 
        ON O."DocEntry" = I."DocEntry"
    LEFT JOIN PCH1 PL 
        ON I."BaseEntry" = PL."DocEntry"
       AND I."ItemCode"  = PL."ItemCode"
    LEFT JOIN OPCH NF 
        ON PL."DocEntry"  = NF."DocEntry"
       AND NF."CANCELED"  = 'N'
    WHERE O."DocEntry" = :list_of_cols_val_tab_del
    AND i."BaseType" = 18
),
CTE_MAX AS (
    SELECT
        REF."DocEntry" AS "NFDocEntry",
        CTE."DocNum"   AS "CTeDocNum",
        CTE."DocDate"  AS "DataCTe",
        ROW_NUMBER() OVER (
            PARTITION BY REF."DocEntry"
            ORDER BY CTE."DocDate" DESC, CTE."DocEntry" DESC
        ) AS RN
    FROM PCH21 REF
    INNER JOIN OPCH CTE
        ON TO_NVARCHAR(CTE."DocEntry") = TO_NVARCHAR(REF."RefDocEntr")
       AND CTE."Model" IN (46,45)
       AND CTE."CANCELED" = 'N'
    WHERE REF."RefObjType" = 18
)
SELECT
    B."OrdemOIPF",
    B."NotaEntrada",
    C."CTeDocNum",
    B."DataOIPF",
    B."DataEntrada",
    C."DataCTe" AS "DataMaxCTe"
FROM BASE B
LEFT JOIN CTE_MAX C
    ON C."NFDocEntry" = B."NFDocEntry"
   AND C.RN = 1
WHERE COALESCE(C."DataCTe", DATE'1900-01-01') <> B."DataOIPF"
)
THEN 
    error := 7;
	error_message := 'A data está diferente do CTE!';
END IF;


WITH CTE_LIST AS (
    SELECT DISTINCT
           O."DocEntry"   AS "ODocEntry",
           O."CostSum"    AS "CostSum",
           CTE."DocEntry" AS "CTEDocEntry"
    FROM OIPF O
    JOIN IPF1 I
      ON O."DocEntry" = I."DocEntry"
    LEFT JOIN PCH1 PL
      ON I."BaseEntry" = PL."DocEntry"
     AND I."ItemCode"  = PL."ItemCode"
    LEFT JOIN OPCH NF
      ON PL."DocEntry" = NF."DocEntry"
     AND NF."CANCELED" = 'N'
    LEFT JOIN PCH21 REF
      ON NF."DocEntry" = REF."DocEntry"
     AND REF."RefObjType" = 18
    LEFT JOIN OPCH CTE
      ON TO_NVARCHAR(CTE."DocEntry") = TO_NVARCHAR(REF."RefDocEntr")
     AND CTE."Model" IN (46,45,152)
     AND CTE."CANCELED" = 'N'
    WHERE O."DocEntry" = :list_of_cols_val_tab_del
      AND CTE."DocEntry" IS NOT NULL
),
CTE_TOT AS (
    SELECT
        L."ODocEntry",
        L."CostSum",
        L."CTEDocEntry",
        SUM(CTELINHA."LineTotal") AS "LineTotalSum",
        IFNULL((
            SELECT SUM("TaxSumSys")
              FROM PCH4
             WHERE "DocEntry" = L."CTEDocEntry"
        ), 0) AS "TaxSum"
    FROM CTE_LIST L
    JOIN PCH1 CTELINHA
      ON CTELINHA."DocEntry" = L."CTEDocEntry"
    GROUP BY L."ODocEntry", L."CostSum", L."CTEDocEntry"
)
SELECT
    IFNULL(SUM("LineTotalSum" - "TaxSum"), 0)                      AS "FreteSemImp",
    IFNULL(SUM("LineTotalSum" - "TaxSum") - MAX("CostSum"), 0)     AS "Diff"
INTO v_frete_sem_imp, v_diff
FROM CTE_TOT;


IF v_diff <> 0 THEN
  error         := 7;
  error_message := 'O valor do frete está errado! Valor correto: ' || v_frete_sem_imp;
END IF;
END IF;
IF :object_type = '18' and (:transaction_type = 'A' OR :transaction_type = 'U') THEN
	IF EXISTS (
	  SELECT
	    1
	  FROM
	    OPCH NOTA
	    left JOIN PCH1 LINHA ON NOTA."DocEntry" = LINHA."DocEntry"
	    LEFT JOIN pch12 ON NOTA."DocEntry" = PCH12."DocEntry"
	    LEFT JOIN PCH21 REF ON NOTA."DocEntry" = REF."DocEntry" AND REF."RefObjType" = 18
	  WHERE
	    PCH12."Incoterms" = 1
	    AND LINHA."Usage" = 15
	    AND NOTA."Model" = 39
	    AND REF."RefDocEntr" IS NULL
	    AND NOTA."CANCELED" = 'N'
	    AND NOTA."DocEntry" = :list_of_cols_val_tab_del
	    AND NOT LINHA."ItemCode" = 'INS0000221'  
	) THEN error:= 7;
	error_message:= 'Nota sem CTE! Favor informe o CTE na referencia da nota.';
	END IF;
	IF EXISTS (
	SELECT
	   1
	FROM
	    OPCH NOTA
	    LEFT JOIN PCH1 LINHA ON NOTA."DocEntry" = LINHA."DocEntry"
	    LEFT JOIN PCH12 ON NOTA."DocEntry" = PCH12."DocEntry"
	    LEFT JOIN PCH21 REF ON NOTA."DocEntry" = REF."DocEntry" AND REF."RefObjType" = 18
	WHERE
	    PCH12."Incoterms" = 1
	    AND LINHA."Usage" = 15
	    AND NOTA."Model" = 39
	    AND NOTA."CANCELED" = 'N'
	    AND NOTA."DocEntry" = :list_of_cols_val_tab_del
	    AND LINHA."ItemCode" <> 'INS0000221'
	    AND NOT EXISTS (
	        SELECT
	            1
	        FROM
	            OPCH NOTA1
	        WHERE
	            (
	                (TO_NVARCHAR(NOTA1."DocEntry") = TO_NVARCHAR(REF."RefDocEntr") 
	                AND NOTA1."Model" in (46,45,152))
	                AND NOTA1."CANCELED" = 'N'
	
	            )
	)
	) THEN error:= 7;
	error_message:= 'Infome um CTE Valido!.';
	END IF;
	IF EXISTS (
	SELECT
	   1
	FROM
	    OPCH NOTA
	    LEFT JOIN PCH1 LINHA ON NOTA."DocEntry" = LINHA."DocEntry"
	    LEFT JOIN PCH12 ON NOTA."DocEntry" = PCH12."DocEntry"
	    LEFT JOIN PCH21 REF ON NOTA."DocEntry" = REF."DocEntry" AND REF."RefObjType" = 18
	WHERE
	    PCH12."Incoterms" = 1
	    AND LINHA."Usage" = 15
	    AND NOTA."Model" = 39
	    AND NOTA."CANCELED" = 'N'
	    AND NOTA."DocEntry" = :list_of_cols_val_tab_del
	    AND LINHA."ItemCode" <> 'INS0000221'
	    AND NOT EXISTS (
	        SELECT
	            1
	        FROM
	            OPCH NOTA1
	            INNER JOIN PCH1 LINHA1 ON NOTA1."DocEntry" = LINHA1."DocEntry" 
	        WHERE
	            (
	                (TO_NVARCHAR(NOTA1."DocEntry") = TO_NVARCHAR(REF."RefDocEntr") 
	                AND NOTA1."Model" in (46,45))
	                AND NOTA1."CANCELED" = 'N'
	                AND LINHA1."Usage" IN (24,34)
	                AND NOTA1."DocDate" = NOTA."DocDate"
	
	            )
	)
	) THEN error:= 7;
	error_message:= 'A data de lançamento da nota deve ser a mesma do CTE!.';
	END IF;
	      IF EXISTS (
	SELECT
	   1
	FROM
	    OPCH NOTA
	    LEFT JOIN PCH1 LINHA ON NOTA."DocEntry" = LINHA."DocEntry"
	    LEFT JOIN PCH21 REF ON NOTA."DocEntry" = REF."DocEntry" AND REF."RefObjType" = 18
	WHERE
	    LINHA."Usage" = 152
	    AND NOTA."Model" = 45
	    AND NOTA."CANCELED" = 'N'
	    AND NOTA."DocEntry" = :list_of_cols_val_tab_del
	    AND NOT EXISTS (
	        SELECT
	            1
	        FROM
	            OPCH NOTA1
	            INNER JOIN PCH1 LINHA1 ON NOTA1."DocEntry" = LINHA1."DocEntry" 
	        WHERE
	            (
	                (TO_NVARCHAR(NOTA1."DocEntry") = TO_NVARCHAR(REF."RefDocEntr") 
	                AND NOTA1."Model" in (46,45))
	                AND NOTA1."CANCELED" = 'N'
	                AND LINHA1."Usage" IN (24,34)
	                AND NOTA1."DocDate" = NOTA."DocDate"
	
	            )
	)
	) THEN error:= 7;
	error_message:= 'Nota de complemento de CTE deve referenciar o CTE de origem!.';
	END IF;
END IF;

IF :object_type = '60' AND :transaction_type = 'A' THEN

    IF EXISTS (
        WITH SAIDA_INSUMO AS (
            SELECT L."ItemCode", L."WhsCode"
              FROM OIGE N
              JOIN IGE1 L ON N."DocEntry" = L."DocEntry"
             WHERE L."DocEntry" = :list_of_cols_val_tab_del
        ),
        ESTOQUE AS (
            SELECT MAX(E."CreatedBy") AS "DocEntry", E."ItemCode"
              FROM OINM E
              JOIN SAIDA_INSUMO S 
                ON E."ItemCode"  = S."ItemCode"
               AND E."Warehouse" = S."WhsCode"
             WHERE E."TransType" = '18'
               AND E."DocDate"   > '2025-07-14'
             GROUP BY E."ItemCode"
        ),
        NOTA AS (
            SELECT N."DocEntry", N."DocNum", L."ItemCode"
              FROM OPCH N
              JOIN PCH1 L       ON N."DocEntry" = L."DocEntry"
              JOIN ESTOQUE E    ON N."DocEntry" = E."DocEntry"
              LEFT JOIN PCH12 P ON N."DocEntry" = P."DocEntry"
             WHERE N."CANCELED"   = 'N'
               AND L."Usage"      = '15'
               AND P."Incoterms"  = 1
               AND N."Model"      = 39
               AND L."ItemCode" <> 'INS0000221'
               AND NOT EXISTS (
                   SELECT 1 
                     FROM IPF1 DI
                    WHERE DI."BaseEntry" = N."DocEntry"
                      AND DI."ItemCode" = L."ItemCode"
               )
        )
        SELECT 1 FROM NOTA
    ) THEN

        SELECT "DocNum"
          INTO notaSemDespesa
          FROM (
            WITH SAIDA_INSUMO AS (
                SELECT L."ItemCode", L."WhsCode"
                  FROM OIGE N
                  JOIN IGE1 L ON N."DocEntry" = L."DocEntry"
                 WHERE L."DocEntry" = :list_of_cols_val_tab_del
            ),
            ESTOQUE AS (
                SELECT MAX(E."CreatedBy") AS "DocEntry", E."ItemCode"
                  FROM OINM E
                  JOIN SAIDA_INSUMO S 
                    ON E."ItemCode"  = S."ItemCode"
                   AND E."Warehouse" = S."WhsCode"
                 WHERE E."TransType" = '18'
                   AND E."DocDate"   > '2025-07-14'
                 GROUP BY E."ItemCode"
            ),
            NOTA AS (
                SELECT N."DocEntry", N."DocNum", L."ItemCode"
                  FROM OPCH N
                  JOIN PCH1 L       ON N."DocEntry" = L."DocEntry"
                  JOIN ESTOQUE E    ON N."DocEntry" = E."DocEntry"
                  LEFT JOIN PCH12 P ON N."DocEntry" = P."DocEntry"
                 WHERE N."CANCELED"   = 'N'
                   AND L."Usage"      = '15'
                   AND P."Incoterms"  = 1
                   AND N."Model"      = 39
                   AND L."ItemCode" <> 'INS0000221'
                       AND NOT EXISTS (
                   SELECT 1 
                     FROM IPF1 DI
                    WHERE DI."BaseEntry" = N."DocEntry"
                      AND DI."ItemCode" = L."ItemCode"
               )
            )
            SELECT "DocNum"
              FROM NOTA
             ORDER BY "DocNum"
             LIMIT 1
        );
        error := 7;
        error_message := 'Não foi feito despesa de importação da nota: ' || notaSemDespesa;

    END IF;
END IF;
end;
