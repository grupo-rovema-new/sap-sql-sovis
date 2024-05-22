CREATE OR REPLACE FUNCTION fncRemove_Acentuacao(val VARCHAR(255))
RETURNS resultado VARCHAR(255) LANGUAGE SQLSCRIPT AS
BEGIN
	resultado := LOWER(val);
	resultado := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(resultado,'á','a'),'à','a'),'â','a'),'ã','a'),'ä','a');
	resultado := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(resultado,'á','a'),'à','a'),'â','a'),'ã','a'),'ä','a');
    resultado :=  REPLACE(REPLACE(REPLACE(REPLACE(resultado,'é','e'),'è','e'),'ê','e'),'ë','e');
    resultado :=  REPLACE(REPLACE(REPLACE(REPLACE(resultado,'í','i'),'ì','i'),'î','i'),'ï','i');
    resultado :=  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(resultado,'ó','o'),'ò','o'),'ô','o'),'õ','o'),'ö','o');
    resultado :=  REPLACE(REPLACE(REPLACE(REPLACE(resultado,'ú','u'),'ù','u'),'û','u'),'ü','u');
   
   resultado :=  REPLACE(REPLACE(REPLACE(REPLACE(resultado,'ú','u'),'ù','u'),'û','u'),'ü','u');
  
  resultado :=  REPLACE(resultado,'ç','c');

   	resultado := REPLACE(resultado,'ý','y');
    resultado := REPLACE(resultado,'ñ','n');
    resultado := REPLACE(resultado,'ç','c');
   
   resultado := REPLACE(resultado,',','');
  
   resultado := REPLACE(resultado,'.','');
   resultado := REPLACE(resultado,'.','');
   resultado := REPLACE(resultado,'ª','');
   resultado := REPLACE(resultado,'º','');
   resultado := REPLACE(resultado,'°','');

   resultado := REPLACE(resultado,'/','');
   resultado := REPLACE(resultado,'//','');
   resultado := REPLACE_REGEXPR('[^a-z0-9-]+' IN resultado WITH ' ');
   resultado := UPPER(resultado);
  
END;




