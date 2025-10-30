CREATE OR replace PROCEDURE "TransNotificationValidate" (	
	companyDB NVARCHAR(128),
	object_type NVARCHAR(30),
	objectEntry NVARCHAR(255),
	OUT errorId INT,	
	OUT errorMesage NVARCHAR(10000)	
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
    entidadeId int;
    is_numeric_result INT;
	quantityOfRecords INT;
	query NVARCHAR(5000);
	tableNamePrefix NVARCHAR(100);
	objValid int;
	BPLId INT;
	prjCode NVARCHAR(100);
	catImpPIS NVARCHAR(20);
	catImpCOFINS NVARCHAR(20);
	catImpPISST NVARCHAR(20);
	catImpCOFINSST NVARCHAR(20);
	catImpICMS NVARCHAR(20);
	catImpIPI NVARCHAR(20);
	catImpISS NVARCHAR(20);
	validacaoAtual nvarchar(60);
    CURSOR queryForValidation  FOR
	    SELECT "Id", "Description", "Query"
	   	FROM "QueryValidation"
	   	WHERE "Enabled" = 1
	   	AND "ObjectId" = object_type
	   	AND IFNULL("Query", '') <> ''
	   	AND "Id" NOT IN (Select "QueryValidationId" FROM "QueryValidationIgnore" Where "EntidadeId" = entidadeId)
	    ORDER BY "Id";
BEGIN	

   Select 
     Count(1)
	 into 
	 objValid
   From "ObjectID" 
   WHERE TO_VARCHAR("Code") =object_type;

   	if object_type='13' OR object_type='15'
	then

	   call "SP_NF22" (CompanyDB,ObjectEntry,1,object_type);

	end if;
  

  IF (IFNULL(errorId,0)=0 and (objValid>0 or object_type='2' or object_type='4')) THEN

			DECLARE EXIT HANDLER FOR SQLEXCEPTION
			BEGIN		
				errorId = ::SQL_ERROR_CODE;
			errorMesage := SUBSTRING(
                  COALESCE(validacaoAtual, '') || '  -  ' || COALESCE(::SQL_ERROR_MESSAGE, ''),
                  1, 200
               );
			END;	
	   	
			SELECT COUNT(1) INTO quantityOfRecords
			FROM M_TEMPORARY_TABLES
			WHERE TABLE_NAME = '#validacaoTabAuxiliar' AND Connection_ID = CURRENT_CONNECTION;		   
			IF quantityOfRecords > 0 
			THEN
				DROP TABLE "#validacaoTabAuxiliar";
			END IF;	
			CREATE LOCAL TEMPORARY TABLE "#validacaoTabAuxiliar" ("campoAuxiliar" nvarchar(100));

		--	--IF object_type = '13'
		--	--THEN a
		--	--	CALL "SP_NF22"(CompanyDB,ObjectEntry,1);
		--	--END IF;
	
	
			query = 'SELECT "Code" FROM "ObjectID" WHERE "Code" NOT IN (17,22) AND TO_VARCHAR("Code") = ''' || object_type || '''';
	
			CALL "CountyRecordsInQuery"(query, quantityOfRecords);	

			IF quantityOfRecords > 0
			THEN	
				SELECT "TableSuffix" 
				INTO tableNamePrefix 
				FROM "ObjectID" 
				WHERE "Code" = object_type;	
		
				object_type = 0;	
		
	   			query = 'SELECT "CompnyName" FROM "' || CompanyDB || '".OADM WHERE IFNULL("MltpBrnchs",''N'') = ''Y''';   
	   
				CALL "CountyRecordsInQuery"(query, quantityOfRecords);
	
				IF (quantityOfRecords > 0 AND IFNULL(tableNamePrefix, '') <> '')
	   			THEN
					query = 'INSERT INTO "#validacaoTabAuxiliar" SELECT "BPLId" FROM "'|| CompanyDB ||'".O' || tableNamePrefix || ' WHERE "DocEntry" = ' || ObjectEntry;	

					EXEC query;

	   				SELECT "campoAuxiliar" INTO BPLId FROM "#validacaoTabAuxiliar";	   	
  				ELSE			
					query = 'INSERT INTO "#validacaoTabAuxiliar" SELECT "Project" FROM "'|| CompanyDB ||'".O' || tableNamePrefix || ' WHERE "DocEntry" = '  || ObjectEntry;
		
					EXEC query;

	   				SELECT "campoAuxiliar" INTO prjCode FROM "#validacaoTabAuxiliar";
				END IF;
			ELSE
				tableNamePrefix = '';
			END IF;

			SELECT TOP 1 "EntidadeId"  INTO entidadeId FROM (
				(SELECT "ID" AS "EntidadeId" 	
   				FROM "Entidade" 
   				WHERE "CompanyDb" =  companyDB 
   				AND IFNULL("ChecarCamposObrigatorios",0) = 1
   				AND (IFNULL(BPLId, 0) <= 0 OR IFNULL("BusinessPlaceId",0) = CAST(IFNULL(BPLId, 0) AS NVARCHAR(10)))
   				ORDER BY "ID")
   	
   				UNION ALL
   		
   				SELECT 0 AS "EntidadeId" FROM DUMMY
			);
   
			IF entidadeId = 0
			THEN
				RETURN;
			END IF;  

			CALL "GetCategoriasImposto"(entidadeId, 3, catImpPIS);
			CALL "GetCategoriasImposto"(entidadeId, 5, catImpCOFINS);
			CALL "GetCategoriasImposto"(entidadeId, 4, catImpPISST);
			CALL "GetCategoriasImposto"(entidadeId, 6, catImpCOFINSST);
			CALL "GetCategoriasImposto"(entidadeId, 1, catImpICMS);
			CALL "GetCategoriasImposto"(entidadeId, 8, catImpIPI);
			CALL "GetCategoriasImposto"(entidadeId, 9, catImpISS);

			FOR cursorRow AS queryForValidation
			DO		
				validacaoAtual =cursorRow."Id" || ' - ' || SUBSTRING(cursorRow."Description", 1, 40) || '...' ;
	
				query = cursorRow."Query";		
	 			query = REPLACE(query,'{companyDb}', IFNULL(companyDB,''));	  
				query = REPLACE(query,'{objectEntry}', IFNULL(objectEntry, ''));	
				query = REPLACE(query,'{tableSuffix}', IFNULL(tableNamePrefix,''));	
				query = REPLACE(query, '{entidadeId}', IFNULL(EntidadeId,0));	
				query = REPLACE(query, '{CatImpPIS}', IFNULL(catImpPIS,''));	    	
				query = REPLACE(query, '{CatImpCOFINS}', IFNULL(catImpCOFINS,''));
				query = REPLACE(query, '{CatImpPISST}', IFNULL(catImpPISST,''));
				query = REPLACE(query, '{CatImpCOFINSST}', IFNULL(catImpCOFINSST,''));	 
				query = REPLACE(query, '{CatImpICMS}', IFNULL(catImpICMS,''));
				query = REPLACE(query, '{CatImpIPI}', IFNULL(catImpIPI,''));
				query = REPLACE(query, '{CatImpISS}', IFNULL(catImpISS,''));

				CALL "CountyRecordsInQuery"(query, quantityOfRecords);	 
		
				IF quantityOfRecords > 0
				THEN
					query = cursorRow."Description";
					query = REPLACE(query,'{companyDb}', IFNULL(companyDB,''));
					query = REPLACE(query,'{objectEntry}', IFNULL(objectEntry,''));
					query = REPLACE(query,'{tableSuffix}', IFNULL(tableNamePrefix,''));
					query = REPLACE(query,'{entidadeId}', IFNULL(entidadeId, 0));
		
		 			errorId = cursorRow."Id";
		 			errorMesage := SUBSTRING(COALESCE(:query, ''), 1, 200);
	   	   
	   				RETURN;
	   			ELSE
	   				validacaoAtual = '';	   		
				END IF;
			END FOR;
	END IF;
END