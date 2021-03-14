RCDFUUI  TITLE 'RCDFUUI - UDF return an UUID'
RCDFUUI  CEEENTRY AUTO=PROGSIZE,MAIN=YES,PLIST=OS
         YREGS
         USING PROGAREA,R13
         LR    R10,R1              Get pointer to parm
* Load Parm
         USING PARM,R10
         L     R6,PTRRES
         L     R7,PTRINDR
         DROP  R10
* Timestamp
         STCKE TIMESTAMP            Get TODE
* SHA-1
         MVC   BLK(20),SHA1
         LA    R0,1                 Function 1: KLMD-SHA-1
         LA    R4,TIMESTAMP         Data addr
         LA    R5,16                Data Length
         LA    R1,BLK               BLK block
         MVC   BLK+20(4),=AL4(0)    0
         MVC   BLK+24(4),=AL4(128) mlb (longitud en bits)
LOOP     KLMD  0,R4                 SHA-1
         BC    1,LOOP               Loop for large blocks
* TROT
         LA    R4,BLK              Ptr to input
         LA    R2,TEMP             Ptr to output
         LA    R3,16               Length
         LA    R1,TABLE            translate table
         TROT  R2,R4,1             Translate 1->2
         JC    1,*-4               Loop if needed
* 8-4-4-4-12
         MVC   0(8,R6),TEMP
         MVI   8(R6),C'-'
         MVC   9(4,R6),TEMP+8
         MVI   13(R6),C'-'
         MVC   14(4,R6),TEMP+12
         MVI   18(R6),C'-'
         MVC   19(4,R6),TEMP+16
         MVI   23(R6),C'-'
         MVC   24(12,R6),TEMP+20
         MVC   0(2,R7),=H'0'       Not null
END      CEETERM  RC=0
*******************************************************************
*  VARIABLE DECLARATIONS AND EQUATES                              *
*******************************************************************
PPA      CEEPPA  ,                 CONSTANTS DESCRIBING THE CODE BLOCK
         LTORG ,                   PLACE LITERAL POOL HERE
SHA1     DS 0D
H0       DC XL4'67452301'
H1       DC XL4'EFCDAB89'
H2       DC XL4'98BADCFE'
H3       DC XL4'10325476'
H4       DC XL4'C3D2E1F0'
TABLE    DS 0D
         dc c'000102030405060708090a0b0c0d0e0f'
         dc c'101112131415161718191a1b1c1d1e1f'
         dc c'202122232425262728292a2b2c2d2e2f'
         dc c'303132333435363738393a3b3c3d3e3f'
         dc c'404142434445464748494a4b4c4d4e4f'
         dc c'505152535455565758595a5b5c5d5e5f'
         dc c'606162636465666768696a6b6c6d6e6f'
         dc c'707172737475767778797a7b7c7d7e7f'
         dc c'808182838485868788898a8b8c8d8e8f'
         dc c'909192939495969798999a9b9c9d9e9f'
         dc c'a0a1a2a3a4a5a6a7a8a9aaabacadaeaf'
         dc c'b0b1b2b3b4b5b6b7b8b9babbbcbdbebf'
         dc c'c0c1c2c3c4c5c6c7c8c9cacbcccdcecf'
         dc c'd0d1d2d3d4d5d6d7d8d9dadbdcdddedf'
         dc c'e0e1e2e3e4e5e6e7e8e9eaebecedeeef'
         dc c'f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff'
PROGAREA DSECT
         ORG   *+CEEDSASZ          LEAVE SPACE FOR DSA FIXED PART
         DS    0D
TIMESTAMP DS   Q
BLK      DS    0D,XL28
TEMP     DS    CL32
PROGSIZE EQU   *-PROGAREA
         CEEDSA  ,                 MAPPING OF THE DYNAMIC SAVE AREA
         CEECAA  ,                 MAPPING OF THE COMMON ANCHOR AREA
PARM     DSECT
PTRRES   DS    A                   Pointer to Result
PTRINDR  DS    A                   Pointer to Result indicator
         END   RCDFUUI
