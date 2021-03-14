//$BUILD   JOB MSGCLASS=X,NOTIFY=&SYSUID
//*---------------------------------------------------------------------
//* Build Db2Funct package
//*---------------------------------------------------------------------
//* Installation instructions:
//* - Customize your job card
//* - Change <thispds> to the name of the source library
//* - Change <loadlib> to the installation load library. Must be a
//*   system LNKLST library or a STEPLIB avialable in the default
//*   WLMPROC for this Db2.
//* - Submit. Must end with rc=0
//* - Refresh the LLA
//*---------------------------------------------------------------------
// SET THISPDS='<thispds>'                     <= Source Library
// SET INSTLIB='<loadlib>'                     <= Instalation load lib
//*---------------------------------------------------------------------
//MAKEASM   PROC M=''
//CLG       EXEC ASMACL,PARM.C='TERM',PARM.L='MAP,LET,LIST'
//C.SYSTERM DD SYSOUT=*
//C.SYSLIB  DD
//          DD DISP=SHR,DSN=SYS1.MODGEN
//          DD DISP=SHR,DSN=CEE.SCEEMAC
//          DD DISP=SHR,DSN=TCPIP.SEZACMAC
//C.SYSIN   DD DISP=SHR,DSN=&THISPDS(&M)
//L.SYSLIB  DD DISP=SHR,DSN=CEE.SCEELKED
//L.SYSLMOD DD DISP=SHR,DSN=&INSTLIB(&M)
//          PEND
//*---------------------------------------------------------------------
//RCDFCSI   EXEC MAKEASM,M='RCDFCSI'
//RCDFDIR   EXEC MAKEASM,M='RCDFDIR'
//RCDFNSL   EXEC MAKEASM,M='RCDFNSL'
//RCDFUUI   EXEC MAKEASM,M='RCDFUUI'
//RCDFWOR   EXEC MAKEASM,M='RCDFWOR'
