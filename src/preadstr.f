      subroutine preadstr(word,latt,twiss,mult,istr,nstr,lfno)
      use tfstk
      use ffs
      use tffitcode
      logical lod,lex,stat,name
      character*(*) word
      character*80 outc,ename,en
      character*255 tfconvstr
C*DEC
      character*255 word2
C*DEC
      dimension latt(2,nlat),twiss(nlat,-ndim:ndim,ntwissfun),mult(*),
     &          istr(nstra,4)
      external pack
      include 'inc/common.inc'
      include 'inc/coroper.inc'
      data in/50/
c
c     call getwdlK(word)
c     call getwdl(word)
      itype=itfpeeko(ia,x,next)
      lfni1=x+.5d0
      if(itype.eq.1) then
        call cssetp(next)
        write(word,'(''ftn'',i2.2)') lfni1
      elseif(itype.eq.101) then
        call cssetp(next)
        word=tfconvstr(101,ia,x,nc,'*')
        if(word.eq.' ') then
          call permes('?Missing filename for MONREAD','.',' ',lfno)
          call getwdl(word)
          return
        endif
        call texpfn(word)
      endif
      inquire(unit=in,opened=lod,iostat=ios)
      if(lod) close(in)
C*DEC
      word2 = word
      inquire(iostat=ios,file=word2,exist=lex)
C*DEC
C*HP
C     inquire(iostat=ios,file=word,exist=lex)
C*HP
      if(.not.lex) then
        
        call permes('?File',word,'not found.',lfno)
        call getwdl(word)
        return
      endif
c 
      open (in,file=word,iostat=ios,status='OLD')
      if(ios .ne. 0) then
        call permes('?Cannot open',word,'.',lfno)
        call getwdl(word)
        return
      endif
c
c     .... reset current specification of Coorectors
      do 10 i=1,nstra
        istr(istr(i,2),3)=1
 10   continue
      stat=.true.
      name=.true.
      jm=0
 1    continue
      call preabuf(outc,in,stat)
      if(stat) goto 99
      if(name) then
        ename=outc
      else
        read(outc,*,err=98) va1
      endif
      name=.not.name
      if(.not.name) goto 1
      ls=jm
      do 20 i=ls+1,nstra
        call elnameK(latt,istr(istr(i,2),1),mult,en)
        if(ename.eq.en) then
          jm=i
          istr(istr(i,2),3)=0
          goto 22
        endif
 20   continue
      do 21 i=ls,1,-1
        call elnameK(latt,istr(istr(i,2),1),mult,en)
        if(ename.eq.en) then
          jm=i
          istr(istr(i,2),3)=0
          goto 22
        endif
 21   continue
      call permes('??',ename,' is not a BEND.',lfno)
      goto 1
c
 22   continue
      rlist(latt(2,istr(istr(jm,2),1))+11)=va1
      goto 1
 98   call permes('??',outc,' is not a number.',lfno)
 99   call pack(istr(1,2),istr(1,3),nstr,nstra)
      write(lfno,'(2(A,I4))')
     1  '  Correction dipole available :',nstr,' in ',nstra
      nstract=nstr
c ....write data in the OPERation buffer.
      if(nstr.ne.0) then
        nstope=nstr
        if(istope.ne.0) then
          call tfree(int8(istope))
        endif
        istope=italoc((nstr+1)/2)
        do 120 i=1,nstr
          ilist(mod(i-1,2)+1,istope+(i-1)/2)=istr(i,2)
 120    continue
      endif
      call getwdl(word)
      close(in)
      return
      end
