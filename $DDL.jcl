//$DDL     JOB MSGCLASS=X,NOTIFY=&SYSUID                                        
//*---------------------------------------------------------------------        
//* Create Db2 functions                                                        
//*---------------------------------------------------------------------        
//* Installation instructions:                                                  
//* - Customize your job card                                                   
//* - Change <db2pref> to the prefix of Db2 SMP software libraries              
//* - Change <runlib> to the RUNLIB where DSNTIAD resisdes in this Db2          
//* - Change <db2sys> to the conection name of this Db2                         
//* - Change <dsntiplan> to the plan name of DSNTIAD                            
//* - Submit. Must end with rc=0, first time may end with rc=8 due to           
//*   DROPs sentences.                                                          
//*---------------------------------------------------------------------        
//DDL       EXEC PGM=IKJEFT01                                                   
//STEPLIB   DD DISP=SHR,DSN=<db2pref>.SDSNLOAD                                  
//          DD DISP=SHR,DSN=<runlib>                                            
//SYSTSPRT  DD SYSOUT=*                                                         
//SYSPRINT  DD SYSOUT=*                                                         
//SYSTSIN   DD *                                                                
DSN SYSTEM(<db2sys>                                                             
  RUN PROGRAM(DSNTIAD) PARM('SQLTERM(#)') PLAN(<dsntiplan>)                     
END                                                                             
//SYSIN     DD *                                                                
  DROP FUNCTION RCDF.CSI#                                                       
  DROP FUNCTION RCDF.NSLOOKUP#                                                  
  DROP FUNCTION RCDF.PDSDIR#                                                    
  DROP FUNCTION RCDF.UUID#                                                      
  DROP FUNCTION RCDF.WORD#                                                      
  DROP SPECIFIC FUNCTION RCDF.POSIXT_TIMESTAMP#                                 
  DROP SPECIFIC FUNCTION RCDF.POSIXT_DATE#                                      
  DROP FUNCTION RCDF.B2H#                                                       
  COMMIT#                                                                       
                                                                                
  CREATE FUNCTION RCDF.CSI                                                      
     (VARCHAR(44),                                                              
      VARCHAR(16))                                                              
    RETURNS TABLE(ENTRY CHAR(44),                                               
                  "TYPE" CHAR(1),                                               
                  VOLSER VARCHAR(256),                                          
                  DEVTYP VARBINARY(256))                                        
    EXTERNAL NAME 'RCDFCSI' LANGUAGE ASSEMBLE                                   
    PARAMETER CCSID EBCDIC  PARAMETER STYLE DB2SQL                              
    DETERMINISTIC FENCED  CALLED ON NULL INPUT  NO SQL                          
    NO EXTERNAL ACTION NO PACKAGE PATH  SCRATCHPAD 512#                         
                                                                                
  CREATE FUNCTION RCDF.NSLOOKUP                                                 
     (VARCHAR(255))                                                             
    RETURNS VARCHAR(255)                                                        
    EXTERNAL NAME 'RCDFNSL' LANGUAGE ASSEMBLE                                   
    PARAMETER CCSID EBCDIC  PARAMETER STYLE DB2SQL                              
    DETERMINISTIC FENCED  CALLED ON NULL INPUT  NO SQL                          
    NO EXTERNAL ACTION NO PACKAGE PATH  SCRATCHPAD 512#                         
                                                                                
  CREATE FUNCTION RCDF.PDSDIR                                                   
     (VARCHAR(44))                                                              
    RETURNS TABLE(MEMBER CHAR(8))                                               
    EXTERNAL NAME 'RCDFDIR' LANGUAGE ASSEMBLE                                   
    PARAMETER CCSID EBCDIC  PARAMETER STYLE DB2SQL                              
    DETERMINISTIC FENCED  CALLED ON NULL INPUT  NO SQL                          
    NO EXTERNAL ACTION NO PACKAGE PATH  SCRATCHPAD 512#                         
                                                                                
  CREATE FUNCTION RCDF.UUID()                                                   
    RETURNS CHAR(36)                                                            
    EXTERNAL NAME 'RCDFUUI' LANGUAGE ASSEMBLE                                   
    PARAMETER CCSID EBCDIC  PARAMETER STYLE DB2SQL                              
    DETERMINISTIC FENCED  CALLED ON NULL INPUT  NO SQL                          
    NO EXTERNAL ACTION NO PACKAGE PATH  SCRATCHPAD 512#                         
                                                                                
  CREATE FUNCTION RCDF.WORD                                                     
     (VARCHAR(255),                                                             
      INTEGER,                                                                  
      VARCHAR(1))                                                               
    RETURNS VARCHAR(255)                                                        
    EXTERNAL NAME 'RCDFWOR' LANGUAGE ASSEMBLE                                   
    PARAMETER CCSID EBCDIC  PARAMETER STYLE DB2SQL                              
    DETERMINISTIC FENCED  CALLED ON NULL INPUT  NO SQL                          
    NO EXTERNAL ACTION NO PACKAGE PATH  SCRATCHPAD 512#                         
                                                                                
  CREATE FUNCTION RCDF.POSIXT                                                   
    (T TIMESTAMP)                                                               
    RETURNS BIGINT                                                              
    SPECIFIC POSIXT_TIMESTAMP                                                   
    LANGUAGE SQL PARAMETER CCSID EBCDIC                                         
    DETERMINISTIC                                                               
    NO EXTERNAL ACTION                                                          
    BEGIN                                                                       
      RETURN CAST(DAYS(DATE(T)) - DAYS('1970-01-01') AS BIGINT)*                
      86400000 + MIDNIGHT_SECONDS(T)* 1000 ;                                    
    END #                                                                       
                                                                                
  CREATE FUNCTION RCDF.POSIXT                                                   
    (D DATE)                                                                    
    RETURNS BIGINT                                                              
    SPECIFIC POSIXT_DATE                                                        
    LANGUAGE SQL PARAMETER CCSID EBCDIC                                         
    DETERMINISTIC                                                               
    NO EXTERNAL ACTION                                                          
    BEGIN                                                                       
      RETURN CAST(DAYS(D) - DAYS('1970-01-01') AS BIGINT)* 86400000 ;           
    END #                                                                       
                                                                                
  CREATE FUNCTION RCDF.B2H                                                      
    (BYTES BIGINT)                                                              
    RETURNS VARCHAR( 32) FOR SBCS DATA CCSID EBCDIC                             
    LANGUAGE SQL PARAMETER CCSID EBCDIC                                         
    DETERMINISTIC                                                               
    NO EXTERNAL ACTION                                                          
    BEGIN                                                                       
      DECLARE B FLOAT ;                                                         
      SET B = FLOAT(BYTES) ;                                                    
      CASE                                                                      
        WHEN BYTES >= 1125899906842624 THEN                                     
          RETURN DECIMAL(B / 1125899906842624 , 10 , 1) || 'PB' ;               
        WHEN BYTES >= 1099511627776 THEN                                        
          RETURN DECIMAL(B / 1099511627776 , 10 , 1) || 'TB' ;                  
        WHEN BYTES >= 1073741824 THEN                                           
          RETURN DECIMAL(B / 1073741824 , 10 , 1) || 'GB' ;                     
        WHEN BYTES >= 1048576 THEN                                              
          RETURN DECIMAL(B / 1048576 , 10 , 1) || 'MB' ;                        
        WHEN BYTES >= 1024 THEN                                                 
          RETURN DECIMAL(B / 1024 , 10 , 1) || 'KB' ;                           
        ELSE                                                                    
          RETURN BYTES || 'B' ;                                                 
      END CASE ;                                                                
    END #                                                                       
IGWFAHR    �      �  �            �   IGWFMO     �                  �    
                                                               �   }   6        
                      D       �   �DFMATTR  ���          Y       �   0FILCLS  
 �