CREATE OR REPLACE VIEW ClienteInadimplentes AS
	SELECT
	    NS."CardCode",
	    P."DueDate",
	    NS."BPLId",
	    p."InsTotal"
	FROM OINV NS
	    INNER JOIN INV6 P ON P."DocEntry" = NS."DocEntry"
	    LEFT  JOIN RCT2 CR ON CR."DocEntry" = NS."DocEntry" AND CR."DocTransId" = NS."TransId" AND CR."InstId" = P."InstlmntID"
	    LEFT  JOIN ORCT OCR ON CR."DocEntry" = OCR."DocEntry"
	WHERE
	    NS."DocStatus" = 'O'
	    AND P."InsTotal" <> '0'
	    AND P."DueDate" < ADD_DAYS(CURRENT_DATE,-2)
	    AND (CR."DocNum" IS NULL AND (OCR."Canceled" = 'N' OR OCR."Canceled" IS NULL))
	    AND NS."CardCode" NOT IN (SELECT "DflCust" FROM OBPL WHERE "DflCust" IS NOT NULL)

	UNION ALL

	/* Adiantamento (ODPI) do contrato de venda futura: o titulo do cliente
	   e a parcela do adiantamento, nao uma nota. Entra a parcela em aberto
	   e vencida, pelo saldo que falta pagar. Adiantamento devolvido (ORIN
	   com BaseType 203) nao conta: o documento fecha mas nao houve pagamento. */
	SELECT
	    AD."CardCode",
	    PA."DueDate",
	    AD."BPLId",
	    PA."InsTotal" - IFNULL(PA."PaidToDate", 0) - IFNULL(PA."TotalBlck", 0) AS "InsTotal"
	FROM ODPI AD
	    INNER JOIN DPI6 PA ON PA."DocEntry" = AD."DocEntry"
	WHERE
	    AD."DocStatus" = 'O'
	    AND AD."CANCELED" = 'N'
	    AND PA."Status" = 'O'
	    AND PA."InsTotal" - IFNULL(PA."PaidToDate", 0) - IFNULL(PA."TotalBlck", 0) > 0
	    AND PA."DueDate" < ADD_DAYS(CURRENT_DATE,-2)
	    AND EXISTS (
	        SELECT 1 FROM "@AR_CONTRATO_FUTURO" ACF
	        WHERE TO_NVARCHAR(ACF."DocEntry") = TO_NVARCHAR(AD."U_venda_futura")
	    )
	    AND NOT EXISTS (
	        SELECT 1
	        FROM RIN1 RL
	            INNER JOIN ORIN R2 ON R2."DocEntry" = RL."DocEntry"
	        WHERE RL."BaseEntry" = AD."DocEntry"
	            AND RL."BaseType" = 203
	            AND R2."CANCELED" = 'N'
	    )
	    AND AD."CardCode" NOT IN (SELECT "DflCust" FROM OBPL WHERE "DflCust" IS NOT NULL)
