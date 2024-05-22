CREATE VIEW SBOGRUPOROVEMA.FILIAIS AS
SELECT 
    "BPLId" ,
    "BPLName" ,
    "BPLFrName" ,
    "VATRegNum" ,
    "RepName" ,
    "Industry" ,
    "Business" , "Address" , "AddressFr" , "MainBPL" , "TxOffcNo" , "Disabled" ,
    "LogInstanc" , "UserSign2" , "UpdateDate" , "DflCust" , "DflVendor" , "DflWhs" ,
    "DflTaxCode" , "RevOffice" , "TaxIdNum" , "TaxIdNum2" , "TaxIdNum3" , "AddtnlId" ,
    "CompNature" , "EconActT" , "CredCOrig" , "IPIPeriod" , "CoopAssocT" , "PrefState" ,
    "ProfTax" , "CompQualif" , "DeclType" , "AddrType" , "Street" , "StreetNo" , "Building" ,
    "ZipCode" , "Block" , "City" , "State" , "County" , "Country" , "PmtClrAct" , "CommerReg" ,
    "DateOfInc" , "SPEDProf" , "EnvTypeNFe" , "Opt4ICMS" , "AliasName" , "GlblLocNum" , "TaxRptFrm" ,
    "Suframa" , "DfltResWhs" , "SnapshotId" , "BPLNum" , "U_LbrAmfsDepEnvioDireto" , "U_LbrAmfsSeqDevNF" ,
    "U_LbrAmfsSeqDevMerc" , "U_Rov_Email" , "U_Rov_Telefone" , "U_LbrAmfsSeqServico" , "U_AtivaForca" ,
    "U_LbrOne_DtIntegracao" , "U_LbrOne_HrIntegracao" , "U_LbrOne_URLIntegracao" , "U_LbrOne_ExpensesToken" 
FROM OBPL;