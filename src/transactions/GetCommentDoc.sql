CREATE OR REPLACE PROCEDURE "GetCommentDoc" 
(
	in pCompanyDb nvarchar(128),
	in pObjId int,
	in pTblSuffix nvarchar(3),
	in pDocEntry int
	
	
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	Declare query nvarchar(1000);
	Declare subqueryObsEntrega nvarchar(1000);
	Declare subqueryObsRegime nvarchar(1000);
	Declare subqueryObsSaida nvarchar(1000);
	subqueryObsEntrega := 'SELECT OBS FROM OBSENTREGA  WHERE OBS IS NOT NULL AND "ObjType" = ' || To_Varchar(pObjId) || ' AND "DocEntry" =' || To_Varchar(pDocEntry);
	subqueryObsRegime := 'SELECT OBS FROM OBSREGIMEESPECIAL WHERE OBS IS NOT NULL AND "DocEntry" =' || To_Varchar(pDocEntry) || ' AND "ObjType" =' || To_Varchar(pObjId);
    subqueryObsSaida := 'SELECT OBS FROM OBSSAIDA WHERE OBS IS NOT NULL AND "DocEntry" =' || To_Varchar(pDocEntry) || ' AND "ObjType" =' || To_Varchar(pObjId);

    query := 'select
				CASE
				WHEN EXISTS(' || subqueryObsEntrega  || '  ) THEN (' || subqueryObsEntrega || ')
				WHEN EXISTS(' || subqueryObsRegime  || '  ) THEN (' || subqueryObsRegime || ')
				WHEN EXISTS(' || subqueryObsSaida  || '  ) THEN (' || subqueryObsSaida || ')
				ELSE
					RTrim(LTrim( IfNull(To_Varchar(T0."Header"),'''') || '' '' || IfNull(To_Varchar(T0."Footer"),'''') ) )
				END as obs
			FROM "' || pCompanyDb ||'"."O'|| pTblSuffix || '"T0
				
			where T0."DocEntry" =' || To_Varchar(pDocEntry);
	
	EXECUTE IMMEDIATE query; 
END