      integer function monqu(latt,pos,n)
      use tfstk
      use ffs
      use tffitcode
      dimension latt(2,nlat),pos(nlat)
      circ=pos(nlat)-pos(1)
      nq=n
      if( idtype(latt(1,n)).ne.icquad .and.
     1    idtype(latt(1,n)).ne.icsext ) then
c     .... search right
10      nq=nq+1
        if(nq.ge.nlat) then
          nq=1
        endif
        if( idtype(latt(1,nq)).ne.icquad .and.
     1      idtype(latt(1,nq)).ne.icsext ) then
          goto 10
        else
          nqr=nq
          posr=mod(pos(nq)-pos(n)+circ,circ )
        endif
c     .... search left
        nq=n
11      nq=nq-1
        if(nq.lt.1) then
          nq=nlat-1
        endif
        if( idtype(latt(1,nq)).ne.icquad .and.
     1      idtype(latt(1,nq)).ne.icsext ) then
          goto 11
        else
          nql=nq
          posl=mod(pos(n)-pos(nq+1)+circ,circ )
        endif
        if(posr.le.posl) then
          nq=nqr
        else
          nq=nql
        endif
      endif
      monqu=nq
      return
      end
