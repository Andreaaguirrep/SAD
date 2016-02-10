      Subroutine ActLie(argp)
      use maccbk
      implicit real*8 (a-h,o-z)
      integer*4 argp
      include 'inc/MACVAR.inc'
C
C      idummy=sethtb('LIE     ',icACT,mfalloc(3))
C      ilist(1,idval(idummy))=2
C      call setfnp(ilist(1,idval(idummy)+1),Act)
C      ilist(1,idval(idummy)+2)=hsrch('USE')
      integer len,idx,hsrchz
      integer rslvin
c
      save
c
      len=ilist(1,argp)
      idx=ilist(2,argp+1)
      nidx=hsrchz('+'//pname(idx))
      idtype(nidx)=idtype(idx)
      if(idval(nidx) .eq. 0) then
        idval(nidx)=rslvin(idx)
      endif
      if (ilist(2,idval(nidx)) .le. 0) then
        call errmsg('ActLie',
     &       'Expanding '//pname(nidx)//' now.',0,0)
        call expnln(nidx)
      endif
      call pr_mem_map
c     call prexln(nidx,'            ')
      call AAALIE(nidx)
      call pr_mem_map
      return
      end
