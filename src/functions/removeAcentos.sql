CREATE OR REPLACE FUNCTION "RemoveAcento"
(pstring nvarchar(200))
RETURNS vString nvarchar(5000) 
LANGUAGE SQLSCRIPT AS

	i int;
	vltOrigem nvarchar(1);
	vltDestino nvarchar(1);
	vorigem nvarchar(200);
	vdestino nvarchar(200);
	
Begin

    vString :=pstring;
	vorigem := '¹²"áàâãª´º°ªÁÀÂÃéèêÉÈÊíìÍÌóòôõºÓÒÔÕúùûÚÙÛçÇçÇçÇÇüéâäàåçêëèïîìÄÅÉôöòûùÿÖÜøáíóúñÑªºÁÂÀãÃÐÊËÈıÍÎÏÌÓßÔÒõÕÚÛÙýÝ';
	vdestino := '12 aaaaa ooaAAAAeeeEEEiiIIoooooOOOOuuuUUUcCcCcCCueaaaaceeeiiiAAEooouuyOU0aiounNaoAAAaADEEEiIIIIObOOoOUUUyY';
	i := 1;
	
	
	while i <= length(vorigem) 
	DO
		vltOrigem := substr(vorigem, i, 1);
		vltDestino := substr(vdestino, i, 1);
		vString := replace(vstring, vltOrigem, vltDestino);
		i := i + 1;

	end while;

end;