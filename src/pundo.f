      subroutine  pundo(latt,twiss,gammab,idp,dp)
      use tfstk
      use ffs
      use tffitcode
      implicit real*8(a-h,o-z)
      logical stab
      dimension latt(2,nlat),twiss(nlat,-ndim:ndim,ntwissfun),
     $     gammab(nlat)
      include 'inc/common.inc'
c
      do 10 i=1,nlat-1
        if(idtype(latt(1,i)).eq.icbend) then
          rlist(latt(2,i)+11)=rlist(ibckup-1+i)
        endif
   10 continue
      do 20 i=1,18
        twiss(1,0,i)=optiv(i)
   20 continue
      if(.not.simulate) then
        call tmov(twiss(1,ndim-2,15),twiss(1,idp,15),nlat)
        call tmov(twiss(1,ndim-2,17),twiss(1,idp,17),nlat)
        call tmov(twiss(1,ndim-2,7),twiss(1,idp,7),nlat)
        call tmov(twiss(1,ndim-2,9),twiss(1,idp,9),nlat)
        return
      endif
      if( cell ) then
        call pqcell(latt,twiss,gammab,idp,dp,stab)
      else
        twiss(1,0,3)=0d0
        twiss(1,0,6)=0d0
        call qtwiss(latt,twiss,gammab,idp,1,nlat,over)
      endif
      return
      end
