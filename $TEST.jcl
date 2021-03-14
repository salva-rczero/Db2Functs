//$TEST    JOB MSGCLASS=X,NOTIFY=&SYSUID
//*---------------------------------------------------------------------
//* Test Db2Funct package
//*---------------------------------------------------------------------
//* Installation instructions:
//* - Customize your job card
//* - Change <db2pref> to the prefix of Db2 SMP software libraries
//* - Change <runlib> to the RUNLIB where DSNTIAD resisdes in this Db2
//* - Change <db2sys> to the conection name of this Db2
//* - Change <dsntep2plan> to the plan name of DSNTEP2
//* - Submit. Must end with rc=0
//*---------------------------------------------------------------------
//DDL       EXEC PGM=IKJEFT01
//STEPLIB   DD DISP=SHR,DSN=<db2pref>.SDSNLOAD
//          DD DISP=SHR,DSN=<runlib>
//SYSTSPRT  DD SYSOUT=*
//SYSPRINT  DD SYSOUT=*
//SYSTSIN   DD *
DSN SYSTEM(<db2sys>)
  RUN PROGRAM(DSNTEP2) PLAN(<dsntep2plan>)
END
//SYSIN     DD *
  SELECT * FROM TABLE(RCDF.CSI('SYS1.**','A')) as T;
  SELECT * FROM TABLE(RCDF.PDSDIR('SYS1.PARMLIB')) as T;
  SELECT RCDF.NSLOOKUP('127.0.0.1') FROM SYSIBM.SYSDUMMY1;
  SELECT RCDF.UUID() FROM SYSIBM.SYSDUMMY1;
  SELECT RCDF.WORD('ISP.SISPLPA',2,'.') FROM SYSIBM.SYSDUMMY1;
  SELECT RCDF.POSIXT_DATE(CURRENT DATE) FROM SYSIBM.SYSDUMMY1;
  SELECT RCDF.POSIXT_TIMESTAMP(CURRENT TIMESTAMP) FROM SYSIBM.SYSDUMMY1;
  SELECT RCDF.B2H(1048576) FROM SYSIBM.SYSDUMMY1;
