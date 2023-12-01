CREATE OR REPLACE VIEW ClienteInadimplentesByContabilidade AS 
SELECT
	tl."ShortName"
FROM
	OJDT t
	LEFT JOIN JDT1 tl on(t."TransId" = tl."TransId")
	LEFT JOIN ITR1 rl on(rl."TransId" = t."TransId")
	LEFT JOIN OITR r ON(r."ReconNum" = rl."ReconNum")
WHERE 
	ADD_DAYS(tl."DueDate", 3) <=  NOW()
	AND tl."ShortName" LIKE 'CLI%'
	AND r."ReconNum" IS NULL
