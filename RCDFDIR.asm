RCDFDIR  TITLE 'RCDFDIR - UDTF list members of a PDS/Library'
RCDFDIR  CEEENTRY AUTO=WORKSIZE,MAIN=YES,PLIST=OS
*----------------------------------------------------------------------
*  RCDFDIR - List PDS directory
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
         mvc   debugt+0(8),=CL8'RCDFDIR'
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
         l     r1,ilib
         clc   0(2,r1),=h'0'
         jne   invalid
         l     r1,lib
         clc   0(2,r1),=h'0'
         je    invalid
         clc   0(2,r1),=h'44'
         jh    invalid
checkpr  l     r14,checkp_s
         br    r14
invalid  l     r1,sqlstate
         mvc   0(5,r1),=CL5'38601'
         l     r1,msgtxt
         mvc   0(2,r1),=h'27'
         mvc   2(27,r1),=cl27'Invalid parm value. Token 1'
         j     checkpr
*----------------------------------------------------------------------
*  Alloc
*----------------------------------------------------------------------
alloc    st    r14,alloc_s
         storage OBTAIN,length=scrsize,loc=24    get working storage
         lr    r9,r1
         using scr,r9
         l     r1,scratch
         st    r9,4(r1)                          save scr in scratch
         mvc   dsntu,=al2(daldsnam)
         mvc   dsntuc,=al2(1)
         l     r1,lib
         lh    r2,0(r1)
         sth   r2,dsntul
mvcdsn   mvc   dsntud(0),2(r1)
         bctr  r2,0
         ex    r2,mvcdsn
         mvc   statustu,=al2(dalstats)
         mvc   statustc,=al2(1)
         mvc   statustl,=al2(1)
         mvi   statustd,x'08'
         mvc   retddnu,=al2(dalrtddn)
         mvc   retddnc,=al2(1)
         mvc   retddnl,=al2(8)
         mvc   retddnd,=cl8' '
         la    r2,ds99
         using s99rbp,r2
         la    r3,s99rbptr+4
         using s99rb,r3
         st    r3,s99rbptr
         oi    s99rbptr,s99rbpnd
         xc    s99rb(rblen),s99rb
         mvi   s99rbln,rblen
         mvi   s99verb,s99vrbal
         la    r4,s99rb+rblen
         using s99tupl,r4
         st    r4,s99txtpp
         la    r5,dsntu
         st    r5,s99tuptr
         la    r4,s99tupl+4
         la    r5,statustu
         st    r5,s99tuptr
         la    r5,retddnu
         using s99tunit,r5
         la    r4,s99tupl+4
         st    r5,s99tuptr
         oi    s99tuptr,s99tupln
         la    r1,ds99
         dynalloc
         ltr   r15,r15
         jnz   allocerr
         mvc   input(minputl),minput
         mvc   open1(mopenl),mopen
         mvc   input+40(8),retddnd
         OPEN  (INPUT,(INPUT)),MODE=31,MF=(E,OPEN1)
         xc    saver3,saver3
allocr   l     r14,alloc_s
         br    r14
allocerr l     r1,sqlstate
         mvc   0(5,r1),=CL5'38602'
         l     r1,msgtxt
         mvc   0(2,r1),=h'26'
         mvc   2(14,r1),=c'Dynalloc error'
         mvc   22(2,r1),S99ERROR
         mvi   24(r1),x'00'
         unpk  17(5,r1),22(3,r1)
         j     allocr
*----------------------------------------------------------------------
*  Free
*----------------------------------------------------------------------
free     st    r14,free_s
         mvc   close1(mclosel),mclose
         CLOSE INPUT,MODE=31,MF=(E,CLOSE1)
         la    r2,ds99
         using s99rbp,r2
         la    r3,s99rbptr+4
         using s99rb,r3
         st    r3,s99rbptr
         oi    s99rbptr,s99rbpnd
         xc    s99rb(rblen),s99rb
         mvi   s99rbln,rblen
         mvi   s99verb,s99vrbun
         la    r4,s99rb+rblen
         using s99tupl,r4
         st    r4,s99txtpp
         mvc   retddnu,=al2(dalddnam)
         la    r5,retddnu
         using s99tunit,r5
         la    r4,s99tupl+4
         st    r5,s99tuptr
         oi    s99tuptr,s99tupln
         la    r1,ds99
         dynalloc
         ltr   r15,r15
         jnz   freeerr
freer    storage RELEASE,length=scrsize,addr=(r9)
         l     r14,free_s
         br    r14
freeerr  l     r1,sqlstate
         mvc   0(5,r1),=CL5'38603'
         l     r1,msgtxt
         mvc   0(2,r1),=h'25'
         mvc   2(19,r1),=c'Dynalloc free error'
         mvc   27(2,r1),S99ERROR
         mvi   29(r1),x'00'
         unpk  22(5,r1),27(3,r1)
         j     freer
*----------------------------------------------------------------------
* Nextmemb
*----------------------------------------------------------------------
nextmemb st    r14,nextmemb_s
         l     r2,saver2
         l     r3,saver3
         ltr   r3,r3
         jnz   skip
nextb    get   input,dirblk
         la    r3,dirblk               Dir Blk addr
         ah    r3,dirblk               + Length
         la    r2,dirblk+2             Start of block
nextm    cr    r2,r3
         jnl   nextb
         using pds2,r2
         cli   pds2name,x'fe'          No tratar undo Endevor
         je    skip
         clc   pds2name,=xl8'ffffffffffffffff' End of dir?
         je    eof
         l     r1,member
         mvc   0(8,r1),pds2name
         l     r1,imember
         mvc   0(2,r1),=h'0'
         j     nextmembr
skip     ic    r1,pds2indc             get bytes
         sll   r1,27                   shift left
         srl   r1,26                   shift right
         la    r2,12(r2,r1)            New offset
         j     nextm
eof      equ   *
         l     r1,sqlstate
         mvc   0(5,r1),=CL5'02000'
nextmembr st   r2,saver2
         st    r3,saver3
         l     r14,nextmemb_s
         br    r14
*----------------------------------------------------------------------
*  constants
*----------------------------------------------------------------------
ppa      ceeppa  ,                 constants describing the code block
         ltorg ,                   place literal pool here
rblen    equ (s99rbend-s99rb)
MINPUT   DCB   DDNAME=INPUT,DSORG=PS,MACRF=GM,RECFM=U,BLKSIZE=256,     +
               EODAD=EOF
minputl  equ   *-minput
MOPEN    OPEN  (,),MODE=31,MF=L
mopenl   equ   *-mopen
MCLOSE   CLOSE (),MODE=31,MF=L
mclosel  equ   *-mclose
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
debug_s  ds    a
wto1     ds    xl(mwtol)
ds99     ds    xl50
debugl   ds    xl2
debugt   ds    cl80
worksize equ   *-worka
*----------------------------------------------------------------------
*  scratchpatch
*----------------------------------------------------------------------
scr      dsect
dsntu    ds    xl2
dsntuc   ds    xl2
dsntul   ds    xl2
dsntud   ds    cl44
statustu ds    xl2
statustc ds    xl2
statustl ds    xl2
statustd ds    c
retddnu  ds    al2(dalrtddn)
retddnc  ds    x'0001'
retddnl  ds    x'0008'
retddnd  ds    cl8
open1    ds    xl(mopenl)
close1   ds    xl(mclosel)
input    ds    xl(minputl)
dirblk   ds    0d,xl256          pds-directory block
saver2   ds    f
saver3   ds    f
scrsize  equ   *-scr
*----------------------------------------------------------------------
*  maps
*----------------------------------------------------------------------
         ceedsa  ,                 mapping of the dynamic save area
         ceecaa  ,                 mapping of the common anchor area
         iefzb4d0
         iefzb4d2
         ihapds pdsbldl=NO,dsect=YES
parm     dsect
lib      ds    a                   pointer to libname
member   ds    a                   pointer to member
ilib     ds    a                   pointer to libname indicator
imember  ds    a                   pointer to member indicator
sqlstate ds    a                   pointer to sql state
family   ds    a                   pointer to function family name
specific ds    a                   pointer to function specific name
msgtxt   ds    a                   pointer to diagnostic message
scratch  ds    a                   pointer to scratch patch area
calltype ds    a                   pointer to call type parameter
         end   RCDFdir
