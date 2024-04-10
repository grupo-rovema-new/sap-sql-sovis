/** TODO
 * [ ] 1 - Identificar os CSTS que sao de venda, e nao esta na tela correta
 * [ ] 2 - Identificar as notas baseado no CST que nao tem conta de contra partida esperada
 * [x] 3 - Verificar as entregas e que nao tem lancamento contabil relacionado
 * [X] 4 - verificar notas ativas no taxone que estao canceladas no SAP - DocEntry OINV de exemplo 7363
 * [ ] 5 - Verificar conta de estoque? Talvez....
 * [ ] 6 - faser trava no desvio do saldo do estoque!?
 * [ ] 7 - Filial nao deveria emitir nota com CFOP 5101 6101
 * [ ] 8 - Notas de venda futura que nao tem lancamento contabil movimentando resultado passivo. (saida, venda)
 * [ ] 9 - Qual CST e do simples faturamento? Nao pode ter esse CST diferente do documento type X
 * [ ] 10 - Qual CST e da venda futura e nao pode estar em tela diferente de entrega
 */
	
SELECT 
	doc."DocEntry",
	doc."DocNum",
	doc."Serial" AS "Numero Nota",
	doc."ObjType" "Codigo Tela",
	itens."CFOPCode" CFOP,
	cfop."Descrip" "CFOP Descricao",
	itens."AcctCode" "Conta Receita",
	filial."BPLName"
FROM
	"OINV" as doc
	INNER JOIN "INV1" as itens on(itens."DocEntry" = doc."DocEntry")
	INNER JOIN "Process" sefaz ON (sefaz."DocType" = doc."ObjType" AND doc."DocEntry" = sefaz."DocEntry")
	INNER JOIN "OBPL" filial ON filial."BPLId" = doc."BPLId"
	LEFT JOIN "OCFP" cfop on(cfop."Code" = itens."CFOPCode")
WHERE
	sefaz."StatusId" = 4
	AND doc."BPLId" IN(2,4,11,17,18)
	
	
SELECT 
	itens."CFOPCode" CFOP,
	(SELECT cfop."Descrip" FROM "OCFP" cfop WHERE(cfop."Code" = itens."CFOPCode"))
FROM
	"OINV" as doc
	INNER JOIN "INV1" as itens on(itens."DocEntry" = doc."DocEntry")
	INNER JOIN "Process" sefaz ON (sefaz."DocType" = doc."ObjType" AND doc."DocEntry" = sefaz."DocEntry")
	INNER JOIN "OBPL" filial ON filial."BPLId" = doc."BPLId"
WHERE
	sefaz."StatusId" = 4
	AND doc."BPLId" IN(2,4,11,17,18)
GROUP BY
	itens."CFOPCode"
	
	
SELECT * FROM "Process" p WHERE "DocEntry" = 7363

SELECT * FROM "OCFP"


	
WHERE

	T0."CANCELED" = 'N'
	AND (T1."Usage"  = 9)
	AND T0."DocDate" >= '2023-01-01'
	AND T0."DocDate" <= '2024-01-31'
	
GROUP BY
	T1."Usage"
	

	

5101
5922
5912
5102
5949
6101
6152
6949
5910
6109
6922
6108
5152
5109
6102
5116
5927
5551
	


	
	
	
	
	
	
	
	
	
	
