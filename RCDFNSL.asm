RCDFNSL  TITLE 'RCDFCSI - UDF NSLookUp from IP addr'
RCDFNSL  CEEENTRY AUTO=PROGSIZE,MAIN=YES,PLIST=OS
         YREGS
         USING PROGAREA,R13
         LR    R10,R1              Get pointer to parm
* Load Parm
         USING PARM,R10
         L     R2,PTRIP
         L     R3,PTRRES
         L     R4,PTRINDI
         L     R5,PTRINDR
         DROP  R10
* Check String
         LH    R1,0(R4)            Load String indicator
         LTR   R1,R1               Check it it is negative
         JM    NULL                If so, result is NULL
* Init TCPIP api
         MVC   MAINTCBC(4),=CL4'ANSL'
         MVC   MAINTCBC+4(4),PSATOLD-PSA(0)
         LA    R8,TIE
         USING EZATASK,R8
         EZASMI TYPE=INITAPI,                                          +
               MAXSNO=MAXSNO,                                          +
               ERRNO=ERRNO,                                            +
               RETCODE=RETCODE,                                        +
               SUBTASK=MAINTCBC,                                       +
               MF=(E,EZASMI1)
         CLC   RETCODE,=F'-1'
         JE    ERROR
* PTON
         EZASMI TYPE=PTON,                                             +
               AF='INET',                                              +
               SRCADDR=2(,R2),                                         +
               SRCLEN=(R2),                                            +
               DSTADDR=ADDR,                                           +
               ERRNO=ERRNO,                                            +
               RETCODE=RETCODE
         CLC   RETCODE,=F'-1'
         JE    ERROR
* GETHOSTBYADDR
         EZASMI TYPE=GETHOSTBYADDR,                                    +
               HOSTADR=ADDR,                                           +
               HOSTENT=HOSTENT,                                        +
               RETCODE=RETCODE
* Term TCPIP api
         EZASMI TYPE=TERMAPI,                                          +
               MF=(E,EZASMI1)
         CLC   RETCODE,=F'-1'
         JE    ERROR
* Get hostname
         L     R2,HOSTENT
         L     R4,0(R2)
         LTR   R4,R4
         JZ    NULL
         LA    R6,2(R3)
         SR    R0,R0
         MVST  R6,R4
         LA    R7,2(R3)
         SR    R6,R7
         STH   R6,0(R3)
         MVC   0(2,R5),=H'0'       Not null
         J     END
NULL     MVC   0(2,R5),=H'-1'      NULL result
         J     END
ERROR    MVC   0(2,R5),=H'-1'      NULL result
         J     END
END      CEETERM  RC=0
*******************************************************************
*  VARIABLE DECLARATIONS AND EQUATES                              *
*******************************************************************
PPA      CEEPPA  ,                 CONSTANTS DESCRIBING THE CODE BLOCK
         LTORG ,                   PLACE LITERAL POOL HERE
PROGAREA DSECT
         ORG   *+CEEDSASZ          LEAVE SPACE FOR DSA FIXED PART
EZASMI1  EZASMI MF=L
MAXSNO   DS    F
ERRNO    DS    F
RETCODE  DS    F
ADDR     DS    F
HOSTENT  DS    F
MAINTCBC DS    CL8
TIE      DS    0D,XL(TIELENTH)
*ZAGLOB  EZASMI TYPE=GLOBAL,STORAGE=DSECT
PROGSIZE EQU   *-PROGAREA
         CEEDSA  ,                 MAPPING OF THE DYNAMIC SAVE AREA
         CEECAA  ,                 MAPPING OF THE COMMON ANCHOR AREA
EZATASK  EZASMI TYPE=TASK,STORAGE=DSECT
         IHAPSA DSECT=YES,LIST=NO
PARM     DSECT
PTRIP    DS    A                   Pointer to String
PTRRES   DS    A                   Pointer to Result
PTRINDI  DS    A                   Pointer to String   indicator
PTRINDR  DS    A                   Pointer to Result indicator
         END   RCDFNSL
