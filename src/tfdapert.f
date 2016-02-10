      subroutine tfdapert(isp1,kx,irtc)
      use tfstk
      implicit none
      include 'inc/TMACRO1.inc'
      integer*8 kx,kc,kac,kcx,kacx,kar
      integer*4 isp1,irtc,narg,i,lfno,nz,itfmessage,np00
      real*8 range(3,3),phix,phiy,damp,rgetgl1
      narg=isp-isp1
      if(narg .ne. 6)then
        irtc=itfmessage(9,'General::narg','"6"')
        return
      endif
      kc=ktastk(isp1+1)
      if(.not. tflistqk(kc))then
        irtc=itfmessage(9,'General::wrongtype','"List for #1"')
        return
      endif
      kac=ktfaddr(kc)
      if(ilist(2,kac-1) .ne. 3)then
        irtc=itfmessage(9,'General::wrongleng','"#1","3"')
        return
      endif
      do i=1,3
        kcx=klist(kac+i)
        if(.not. tfreallistq(kcx))then
          return
        endif
        kacx=ktfaddr(kcx)
        if(i .lt. 3)then
          if(ilist(2,kacx-1) .ne. 2)then
            return
          endif
          range(1,i)=rlist(kacx+1)
          range(2,i)=rlist(kacx+2)
        endif
      enddo
      nz=min(200,np0,ilist(2,kacx-1))
      if(ktfnonrealq(ktastk(isp1+2)))then
        return
      endif
      lfno=int(rtastk(isp1+2))
      if(ktflistq(ktastk(isp1+3)))then
        kar=ktfaddr(ktastk(isp))
        if(ilist(2,kar-1) .ne. 6 .or.ktfnonreallistq(kar))then
          irtc=itfmessage(9,'General::wrongtype',
     $         '"{x0, px0, y0, py0, z0, dp0} for #3"')
          return
        endif
        call tmov(rlist(kar+1),codin,6)
      endif
      if(ktfnonrealq(ktastk(isp1+4)))then
        irtc=itfmessage(9,'General::wrongtype',
     $       '"PhaseX for #4"')
        return
      endif
      phix=rtastk(isp1+4)
      if(ktfnonrealq(ktastk(isp1+5)))then
        irtc=itfmessage(9,'General::wrongtype',
     $       '"PhaseY for #5"')
        return
      endif
      phiy=rtastk(isp1+5)
      if(ktfnonrealq(ktastk(isp1+6)))then
        irtc=itfmessage(9,'General::wrongtype',
     $       '"damp for #6"')
        return
      endif
      damp=rtastk(isp1+6)
      np00=np0
      np0=max(2000,nz*max(1,nint(rgetgl1('DAPWIDTH'))))
      call tfdapert1(ilist(1,ilattp+1),
     $     range,rlist(kacx+1),nz,kx,phix,phiy,damp,lfno)
      np0=np00
      irtc=0
      return
      end

      subroutine tfdapert1(latt,range,rz,nz,trval,phix,phiy,damp,lfno)
      use tfstk
      implicit none
      include 'inc/TMACRO1.inc'
      integer*4 latt(2,nlat),kptbl(np0,6),lfno,mturn(np0),kzx(2,np0),
     $     nz,itgetfpe
      real*8 x(np0),px(np0),y(np0),py(np0),z(np0),g(np0),dv(np0),
     1     pz(np0),trval,phix,phiy,range(3,3),rz(nz),codsave(6),damp
      logical*4 dapert0
      call tmov(codin,codsave,6)
      call tfsetparam
      dapert0=dapert
      dapert=.true.
      x(1)=range(1,1)
      x(2)=range(2,1)
      y(1)=range(1,2)
      y(2)=range(2,2)
      call tmov(rz,g(1),nz)
      pz(1)=nz
      call tclr(kptbl,np0*3)
      call tspini(1,kptbl,.false.)
      call trackd(latt,kptbl,x,px,y,py,z,g,dv,pz,
     1     mturn,kzx,trval,phix,phiy,damp,lfno)
      dapert=dapert0
      if(itgetfpe() .ne. 0)then
        write(*,*)'DynamicApertureSurvey-FPE ',itgetfpe()
        call tclrfpe
      endif
      call tmov(codsave,codin,6)
      return
      end
