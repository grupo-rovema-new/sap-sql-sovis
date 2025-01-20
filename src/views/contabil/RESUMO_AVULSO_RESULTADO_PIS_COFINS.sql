SELECT 
L."BPLId",
L."BPLName",
C."AcctCode" || ' - ' || C."AcctName" AS "Conta gerencial",
CC."PrcCode" || ' - ' || CC."PrcName" AS "Departamento",
SUM("Credit" - "Debit") AS "Base de calculo",
0.65 AS "PIS%",
SUM("Credit" - "Debit") * 0.0065 AS "Valor do PIS",
4 AS "CONFIS%",
SUM("Credit" - "Debit") * 0.04 AS "Valor do CONFINS"
FROM JDT1 L
INNER JOIN OJDT LC  ON L."TransId" = LC."TransId" 
INNER JOIN OACT C ON L."Account" = C."AcctCode" 
LEFT JOIN  OPRC CC ON L."OcrCode2" = CC."PrcCode" 
WHERE "Account"  IN ('3.1.3.001.00002','3.1.3.001.00003','3.1.3.001.00004','3.1.3.001.00008','3.1.3.001.00010')
AND L."RefDate" >= :Data
AND L."RefDate" <= :Data1
AND L."BPLId" = 2
GROUP BY 
C."AcctCode" || ' - ' || C."AcctName",
CC."PrcCode" || ' - ' || CC."PrcName",
L."BPLId",
L."BPLName"




