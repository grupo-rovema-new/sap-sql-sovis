CREATE OR REPLACE VIEW ClienteInadimplentes AS
	SELECT
	    NS."CardCode",
	    NS."BPLId" 
	FROM OINV NS
	    INNER JOIN INV6 P ON P."DocEntry" = NS."DocEntry"
	    LEFT  JOIN RCT2 CR ON CR."DocEntry" = NS."DocEntry" AND CR."DocTransId" = NS."TransId" AND CR."InstId" = P."InstlmntID"
	    LEFT  JOIN ORCT OCR ON CR."DocEntry" = OCR."DocEntry"
	WHERE
	    NS."DocStatus" = 'O'
	    AND P."InsTotal" <> '0'
	    AND P."DueDate" >= ADD_DAYS(NOW(),2)
	    AND (CR."DocNum" IS NULL AND (OCR."Canceled" = 'N' OR OCR."Canceled" IS NULL))