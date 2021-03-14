RCDFWOR  TITLE 'RCDFWOR - Return n-word from String with separator'
RCDFWOR  CEEENTRY AUTO=PROGSIZE,MAIN=YES,PLIST=OS
         YREGS
         USING PROGAREA,R13
         LR    R10,R1              Get pointer to parm
* Load Parm
         USING PARM,R10
         L     R2,PTRSTR
         L     R3,PTRPOS
         L     R4,PTRCHR
         L     R5,PTRRES
         L     R6,PTRINDS
         L     R7,PTRINDP
         L     R8,PTRINDC
         L     R9,PTRINDR
         DROP  R10
* Check String
         LH    R1,0(R6)            Load String indicator
         LTR   R1,R1               Check it it is negative
         JM    NULL                If so, result is NULL
* Check Position
         LH    R1,0(R7)            Load Position indicator
         LTR   R1,R1               Check it it is negative
         JM    NULL                If so, result is NULL
         L     R1,0(R3)            Load Position
         LTR   R1,R1               Check it it is negative or zero
         JNP   NULL                If so, result is NULL
* Check Char
         LH    R1,0(R8)            Load Char indicator
         LTR   R1,R1               Check it it is negative
         JM    DEFCHAR             If so, result is NULL
         MVC   CHAR,2(R4)          Copy Char
         J     MAIN
DEFCHAR  MVI   CHAR,C' '           Default char is blank
* Main proc
MAIN     EQU   *
         LH    R10,0(R2)           String length
         LA    R2,2(R2)            String start
         L     R3,0(R3)            Word position
         LA    R4,1                Current Word
         SR    R6,R6               Result length
         LA    R7,2(R5)            Result start
LOOP     CLC   0(1,R2),CHAR        Test char
         JNE   NCHAR               Not separator
         LA    R4,1(R4)            Current Word += 1
         LA    R2,1(R2)            Next position
         BCT   R10,LOOP            Loop
         J     ENDSTR              End of String
NCHAR    CR    R4,R3               Word = My Word ?
         JE    CPCH                Yes, copy
         JH    ENDSTR              Terminated?
         LA    R2,1(R2)            Source position += 1
         BCT   R10,LOOP            Loop
         J     ENDSTR
CPCH     MVC   0(1,R7),0(R2)       Copy result
         LA    R7,1(R7)            Dest position += 1
         LA    R2,1(R2)            Source position += 1
         LA    R6,1(R6)            Used Length += 1
         BCT   R10,LOOP            Loop
ENDSTR   STH   R6,0(R5)            Save result length
         MVC   0(2,R9),=H'0'       Not null
         J     END
NULL     MVC   0(2,R9),=H'-1'      NULL result
END      CEETERM  RC=0
*******************************************************************
*  VARIABLE DECLARATIONS AND EQUATES                              *
*******************************************************************
PPA      CEEPPA  ,                 CONSTANTS DESCRIBING THE CODE BLOCK
         LTORG ,                   PLACE LITERAL POOL HERE
PROGAREA DSECT
         ORG   *+CEEDSASZ          LEAVE SPACE FOR DSA FIXED PART
CHAR     DS    C
PROGSIZE EQU   *-PROGAREA
         CEEDSA  ,                 MAPPING OF THE DYNAMIC SAVE AREA
         CEECAA  ,                 MAPPING OF THE COMMON ANCHOR AREA
PARM     DSECT
PTRSTR   DS    A                   Pointer to String
PTRPOS   DS    A                   Pointer to Position
PTRCHR   DS    A                   Pointer to Chr
PTRRES   DS    A                   Pointer to Result
PTRINDS  DS    A                   Pointer to String   indicator
PTRINDP  DS    A                   Pointer to Position indicator
PTRINDC  DS    A                   Pointer to Chr indicator
PTRINDR  DS    A                   Pointer to Result indicator
         END   RCDFWOR
