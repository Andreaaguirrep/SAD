      subroutine twelm(lfno,latt,mult,idisp1,idisp2,title,irmgn,itab)
      use ffs
      use tffitcode
      dimension latt(2,nlat),mult(nlat)
      character*(*) title
      character*16 name,name1,title1
      call elname(latt,idisp1,mult,name)
      if(idisp2 .gt. 0)then
        call elname(latt,idisp2,mult,name1)
      else
        name1=' '
      endif
      title1=title
      call twbuf(
     1    title1(1:lene(title1))//' '//name(1:lene(name))//' '//name1,
     1    lfno,1,irmgn,itab,1)
      return
      end
