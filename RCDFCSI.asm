RCDFCSI  TITLE 'RCDFCSI - UDTF call Catalog Search Interface'
RCDFCSI  CEEENTRY AUTO=WORKSIZE,MAIN=YES,PLIST=OS
*----------------------------------------------------------------------
*  RCDFCSI - Catalog Search Interface
*----------------------------------------------------------------------
         yregs
         using worka,r13
         lr    r10,r1              get pointer to parm
         using parm,r10
*        bras  r14,debug
         l     r1,scratch
         l     r9,4(r1)              get scr
         l     r2,calltype
         clc   0(4,r2),=F'-2'        SQLUDF_TF_FIRST -2
         jne   open
         bras  r14,checkp
         j     end
open     clc   0(4,r2),=F'-1'        SQLUDF_TF_OPEN  -1
         jne   fetch
         bras  r14,alloc
         j     end
fetch    clc   0(4,r2),=F'0'         SQLUDF_TF_FETCH  0
         jne   close
         bras  r14,nextmemb
         j     end
close    clc   0(4,r2),=F'1'         SQLUDF_TF_CLOSE  1
         jne   final
         bras  r14,free
         j     end
final    clc   0(4,r2),=F'2'         SQLUDF_TF_FINAL  2
         jne   end
end      ceeterm rc=0
*----------------------------------------------------------------------
*  debug
*----------------------------------------------------------------------
debug    st    r14,debug_s
         mvc   debugl(2),=al2(80)
         mvc   debugt,=cl80' '
         mvc   debugt+0(8),=CL8'RCDFCSI'
         l     r1,calltype
         mvc   debugt+10(4),0(r1)
         l     r1,sqlstate
         mvc   debugt+20(5),0(r1)
         mvc   wto1(mwtol),mwto
         la    r3,debugl
         wto   text=(r3),mf=(E,wto1)
         l     r14,debug_s
         br    r14
*----------------------------------------------------------------------
*  Checkp
*----------------------------------------------------------------------
checkp   st    r14,checkp_s
* mask
         l     r1,imask
         clc   0(2,r1),=h'0'
         jne   invalid
         l     r1,mask
         clc   0(2,r1),=h'0'
         je    invalid
         clc   0(2,r1),=h'44'
         jh    invalid
* seltype
         l     r1,iseltype
         clc   0(2,r1),=h'0'
         je    checkpr
         l     r1,seltype
         clc   0(2,r1),=h'16'
         jh    invali2
checkpr  l     r14,checkp_s
         br    r14
invalid  l     r1,sqlstate
         mvc   0(5,r1),=CL5'38601'
         l     r1,msgtxt
         mvc   0(2,r1),=h'27'
         mvc   2(27,r1),=cl27'Invalid parm value. Token 1'
         j     checkpr
invali2  l     r1,sqlstate
         mvc   0(5,r1),=CL5'38601'
         l     r1,msgtxt
         mvc   0(2,r1),=h'27'
         mvc   2(27,r1),=cl27'Invalid parm value. Token 2'
         j     checkpr
*----------------------------------------------------------------------
*  Alloc
*----------------------------------------------------------------------
alloc    st    r14,alloc_s
         storage OBTAIN,length=scrsize,loc=31 working storage
         lr    r9,r1
         using scr,r9
         l     r1,scratch
         st    r9,4(r1)                          save scr in scratch
         la    r2,selcrita
         using csifield,r2
         mvc   csicatnm,=cl44' '
         mvc   csiresnm,=cl44' '
         mvc   csidtypd(16),=cl16' '
         mvc   csiopts,=c'Y   '
         mvc   csinumen,=h'2'
         mvc   csifiltk,=cl44' '
         l     r1,mask
         lh    r3,0(r1)
         bctr  r3,0
movefil  mvc   csifiltk(0),2(r1)
         ex    r3,movefil
         l     r1,seltype
         ltr   r1,r1
         jz    entries
         lh    r3,0(r1)
         ltr   r3,r3
         jz    entries
         bctr  r3,0
movesel  mvc   csidtypd(0),2(r1)
         ex    r3,movesel
entries  mvc   csients(16),=cl16'VOLSER  DEVTYP  '
         drop  r2
         mvc   buffcsi+0(4),=al4(l'buffcsi)
         la    r1,reasona
         st    r1,w1
         la    r1,selcrita
         st    r1,w2
         la    r1,buffcsi
         st    r1,w3
         oi    w3,x'80'
         bras  r14,callcsi
         c     r15,=f'8'
         jnl   allocerr
allocr   l     r14,alloc_s
         br    r14
allocerr l     r1,sqlstate
         mvc   0(5,r1),=cl5'38602'
         l     r1,msgtxt
         mvc   0(2,r1),=h'26'
         mvc   2(14,r1),=c'CSI error, rs:'
         mvc   22(4,r1),reasona
         mvi   26(r1),x'00'
         unpk  17(9,r1),22(5,r1)
         j     allocr
*----------------------------------------------------------------------
*  Call CSI
*----------------------------------------------------------------------
callcsi  st    r14,callcsi_s
         la    r1,w1
         link  ep=IGGCSI00
         la    r1,buffcsi
         using csirwork,r1
         lr    r3,r1
         a     r3,csiusdln
         la    r2,head_end
         lh    r6,csinumfd
         drop  r1
         st    r2,saver2
         st    r3,saver3
         st    r6,saver6
         l     r14,callcsi_s
         br    r14
*----------------------------------------------------------------------
*  Free
*----------------------------------------------------------------------
free     st    r14,free_s
         storage RELEASE,length=scrsize,addr=(r9)
         l     r14,free_s
         br    r14
*----------------------------------------------------------------------
* Nextmemb
*----------------------------------------------------------------------
nextmemb st    r14,nextmemb_s
         l     r2,saver2
         l     r3,saver3
         l     r6,saver6
         using iggcsi_entry,r2
nextb    cr    r2,r3
         jnl   eob
         cli   csietype,x'F0' Cat Entry
         jne   entr
         drop  r2
         using iggcsi_catalog,r2
         la    r2,csicente
         j     nextb
         drop  r2
         using iggcsi_entry,r2
entr     bras  r14,fields
         tm    csieflag,csienter
         bo    nodata
         lh    r1,csitotln
         b     nextryp
nodata   la    r1,4
nextryp  la    r2,csiedata
         ar    r2,r1
         drop  r2
nextmembr st   r2,saver2
         l     r14,nextmemb_s
         br    r14
eof      equ   *
         l     r1,sqlstate
         mvc   0(5,r1),=CL5'02000'
         j     nextmembr
eob      la    r1,selcrita
         using csifield,r1
         cli   csiresum,c'Y'
         jne   eof
         drop  r1
         bras  r14,callcsi
         c     r15,=f'8'
         jl    nextb
         l     r1,sqlstate
         mvc   0(5,r1),=cl5'38602'
         l     r1,msgtxt
         mvc   0(2,r1),=h'26'
         mvc   2(14,r1),=c'CSI error, rs:'
         mvc   22(4,r1),reasona
         mvi   26(r1),x'00'
         unpk  17(9,r1),22(5,r1)
         j     nextmembr
*----------------------------------------------------------------------
* Fields
*----------------------------------------------------------------------
fields   st    r14,fields_s
         using iggcsi_entry,r2
fname    l     r1,entry
         mvc   0(44,r1),csiename
         l     r1,ientry
         mvc   0(2,r1),=h'0'
ftype    l     r1,type
         mvc   0(1,r1),csietype
         l     r1,itype
         mvc   0(2,r1),=h'0'
         la    r4,csilenf1
         lr    r7,r4
         bctr  r6,0
         sll   r6,1
         ar    r7,r6
         tm    csieflag,csiedata_f
         jz    eor
fvolser  l     r1,ivolser
         mvc   0(2,r1),=h'-1'
         lh    r5,0(r4)
         ch    r5,=h'0'
         jle   fdevt
         l     r1,volser
         sth   r5,0(r1)
         bctr  r5,0
movvol   mvc   2(0,r1),0(r7)
         ex    r5,movvol
         ar    r7,r5
         la    r7,1(r7)
         l     r1,ivolser
         mvc   0(2,r1),=h'0'
fdevt    la    r4,2(r4)
         l     r1,idevtype
         mvc   0(2,r1),=h'-1'
         lh    r5,0(r4)
         ch    r5,=h'0'
         jle   eor
         l     r1,devtype
         sth   r5,0(r1)
         bctr  r5,0
movdev   mvc   2(0,r1),0(r7)
         ex    r5,movdev
         ar    r7,r5
         la    r7,1(r7)
         l     r1,idevtype
         mvc   0(2,r1),=h'0'
eor      l     r14,fields_s
         br    r14
         drop  r2
*----------------------------------------------------------------------
*  constants
*----------------------------------------------------------------------
ppa      ceeppa  ,                 constants describing the code block
         ltorg ,                   place literal pool here
mwto     WTO   TEXT=,MF=L
mwtol    EQU   *-mwto
*----------------------------------------------------------------------
*  work
*----------------------------------------------------------------------
worka    dsect
         org   *+ceedsasz          leave space for dsa fixed part
         ds    0d
alloc_s  ds    a
free_s   ds    a
checkp_s ds    a
nextmemb_s ds  a
callcsi_s ds   a
fields_s ds    a
debug_s  ds    a
wto1     ds    xl(mwtol)
debugl   ds    xl2
debugt   ds    cl80
worksize equ   *-worka
*----------------------------------------------------------------------
*  workarea en scratchpad
*----------------------------------------------------------------------
scr      dsect
saver2   ds    f
saver3   ds    f
saver6   ds    f
w1       ds    a
w2       ds    a
w3       ds    a
reasona  ds    f
         ds    0d
selcrita ds    xl(l_csifield)
l_csifield equ (csients-csifield)+800
         ds    0d
buffcsi  ds    xl(64000)
scrsize  equ   *-scr
*----------------------------------------------------------------------
*  mapas
*----------------------------------------------------------------------
         ceedsa  ,                 mapping of the dynamic save area
         ceecaa  ,                 mapping of the common anchor area
         COPY  IGGCSINA
CSIRWORK DSECT                CSI RETURN WORK AREA
CSIUSRLN DS    F              TOTAL LENGTH OF WORK AREA. USER PROVIDED.
CSIREQLN DS    F              MINIMUM REQUIRED WORK AREA FOR 1 CATALOG
*                             NAME ENTRY AND 1 DATA ENTRY
CSIUSDLN DS    F              TOTAL LENGTH OF WORK AREA USED IN
*                             RETURNING ENTRIES.
CSINUMFD DS    H              NUMBER OF FIELD NAMES PLUS 1.
HEAD_END EQU   *
*
IGGCSI_CATALOG DSECT
CSISFLG  DS    X              CATALOG FLAG INFORMATION
CSINTICF EQU   X'80'          NON-ICF CATALOG, NOT SUPPORTED.
CSINOENT EQU   X'40'          NO ENTRY FOUND FOR THIS CATALOG.
CSINTCMP EQU   X'20'          DATA GOTTEN FOR THIS CATALOG IS NOT
*                             COMPLETE.
CSICERR  EQU   X'10'          WHOLE CATALOG NOT PROCESSED DUE TO ERROR.
CSICERRP EQU   X'08'          CATALOG PARTIALLY PROCESSED DUE TO ERROR.
*              X'07'          RESERVED.
CSICTYPE DS    C              CATALOG TYPE. HEX 'F0'
CSICNAME DS    CL44           CATALOG NAME
CSICRETN DS    0CL4           RETURN INFORMATION FOR CATALOG.
CSICRETM DS    CL2            CATALOG RETURN MODULE ID
CSICRETR DS    X              CATALOG RETURN REASON CODE
CSICRETC DS    X              CATALOG RETURN CODE
CSICENTE EQU   *
*
IGGCSI_ENTRY   DSECT
CSIEFLAG DS    X              ENTRY FLAG INFORMATION.
CSIPMENT EQU   X'80'          PRIMARY ENTRY.
*        0.... ....           THIS ENTRY ASSOCIATES
*                             WITH THE PRECEDING
*                             PRIMARY ENTRY.
CSIENTER EQU   X'40'          ERROR INDICATION IS SET
*                             FOR THIS ENTRY AND ERROR
*                             CODE FOLLOWS CSIENAME.
CSIEDATA_F EQU   X'20'        DATA IS RETURNED FOR
*                             THIS ENTRY.
*        ...1 1111            RESERVED.
CSIETYPE DS    C              ENTRY TYPE.
*                               A NON-VSAM DATA SET
*                               B GENERATION DATA GROUP
*                               C CLUSTER
*                               D DATA COMPONENT
*                               G ALTERNATE INDEX
*                               H GENERATION DATA SET
*                               I INDEX COMPONENT
*                               R PATH
*                               X ALIAS  (MVS/DFP 3.2.0.AND LATER ONLY)
*                               U USER CATALOG CONNECTOR ENTRY
*                                 (MVS/DFP 3.2.0 AND LATER ONLY)
*                               L ATL LIBRARY ENTRY
*                                 (DFSMS/MVS 1.1.0 AND LATER ONLY)
*                               W ATL VOLUME ENTRY
*                                 (DFSMS/MVS 1.1.0 AND LATER ONLY)
CSIENAME DS    CL44             ENTRY NAME.
CSIERETN DS    0CL4             ERROR RETURN INFORMATION
*                               FOR ENTRY. ONLY EXISTS
*                               IF CSIENTER IS 1.
CSIERETM DS    CL2              ENTRY RETURN MODULE ID
CSIERETR DS    X                ENTRY RETURN REASON CODE
CSIERETC DS    X                ENTRY RETURN CODE
         ORG   CSIERETN
CSIEDATA EQU   *                RETURNED DATA FOR ENTRY.
*                               ONLY EXISTS IF CSIENTER
*                               IS 0.
CSITOTLN DS    XL2              TOTAL LENGTH OF RETURNED
*                               INFORMATION INCLUDING
*                               THIS FIELD AND LENGTH
*                               FIELDS. THE NEXT ENTRY
*                               BEGINS AT THIS OFFSET
*                               PLUS THIS LENGTH.
         DS    XL2              RESERVED.
CSILENFD DS    0XL2             LENGTH OF FIELDS. THERE
*                               IS ONE LENGTH FIELD
*                               RETURNED FOR EACH FIELD
*                               NAME PASSED ON INPUT.
CSILENF1 DS    XL2              FIRST LENGTH FIELD.
*
IGGCSI_FIELD   DSECT
CSIFDDAT EQU   *                FIELD DATA. FOR EACH
*                               FIELD NAME PASSED ON
*                               INPUT, THERE WILL BE A
*                               DATA ITEM CORRESPONDING
*                               TO ITS LENGTH.
*                               THE NEXT ENTRY WOULD
*                               BEGIN HERE IF MORE THAN
*                               1 ENTRY IS RETURNED.
*                               THE NEXT CATALOG ENTRY
*                               WOULD BEGIN AFTER ALL OF
*                               THE ENTRIES IF MORE THAN
*                               1 CATALOG IS SEARCHED.
parm     dsect
mask     ds    a                   pointer to mask - input
seltype  ds    a                   pointer to seltype - input
entry    ds    a                   pointer to entry - output
type     ds    a                   pointer to type  - output
volser   ds    a                   pointer to volser- output
devtype  ds    a                   pointer to devtype - output
imask    ds    a                   pointer to mask indicator
iseltype ds    a                   pointer to seltype indicator
ientry   ds    a                   pointer to entry indicator
itype    ds    a                   pointer to type indicator
ivolser  ds    a                   pointer to volser indicator
idevtype ds    a                   pointer to devtype indicator
sqlstate ds    a                   pointer to sql state
family   ds    a                   pointer to function family name
specific ds    a                   pointer to function specific name
msgtxt   ds    a                   pointer to diagnostic message
scratch  ds    a                   pointer to scratch patch area
calltype ds    a                   pointer to call type parameter
         end   RCDFCSI
