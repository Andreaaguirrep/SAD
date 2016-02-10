      subroutine tfreplace(k,kr,kx,all,eval,rule,irtc)
      use tfstk
      implicit none
      type (sad_descriptor) k,kr,kx,ki
      type (sad_list), pointer :: lri,lr,klr
      integer*4 irtc,i,nrule,isp1,j,itfmessage
      logical*4 all,eval,rep,rule,symbol,tfconstpatternqk
      irtc=0
      isp1=isp
      symbol=.true.
      if(tflistqd(kr,klr))then
        call tfflattenstk(klr,-1,ktfoper+mtflist,irtc)
        if(irtc .ne. 0)then
          go to 9000
        endif
        nrule=isp-isp1
        do i=isp,isp1+1,-1
          ki=dtastk(i)
          if(tfruleqk(ki%k,lri))then
            j=i+i-isp1
            ktastk(j-1:j)=lri%body(1:2)
            if(.not. tfconstpatternqk(ktastk(j-1)))then
              ivstk2(2,j-1)=1
            else
              ivstk2(2,j-1)=0
            endif
            symbol=symbol .and.
     $           iand(ktfmask,ktastk(j-1)) .eq. ktfsymbol
          elseif(ki%k .eq. ktfoper+mtfnull)then
            ktastk(i+i-isp1-1:isp+nrule-2)=ktastk(i+i-isp1+1:isp+nrule)
            nrule=nrule-1
          else
            irtc=itfmessage(9,'General::wrongtype',
     $           '"Rule or List of rules"')
            go to 9000
          endif
        enddo
        isp=isp+nrule
      elseif(tfruleqk(kr%k,lr))then
        call tfgetllstkall(lr)
        if(.not. tfconstpatternqk(ktastk(isp-1)))then
          ivstk2(2,isp-1)=1
        else
          ivstk2(2,isp-1)=0
        endif
        symbol=iand(ktfmask,ktastk(isp-1)) .eq. ktfsymbol
        nrule=1
      else
        irtc=itfmessage(9,'General::wrongtype',
     $           '"Rule or List of rules"')
        go to 9000
      endif
      if(rule)then
        return
      endif
      if(nrule .le. 0)then
        kx=k
      else
        if(symbol)then
          call tfreplacesymbolstk(k,isp1,nrule,kx,.false.,rep,irtc)
        else
          call tfinitrule(isp1,nrule)
          call tfreplacestk(k,isp1,nrule,kx,all,rep,irtc)
          call tfresetrule(isp1,nrule)
        endif
      endif
      if(eval .and. rep .and. irtc .eq. 0)then
        call tfeevalref(kx,kx,irtc)
      endif
 9000 isp=isp1
      return
      end

      subroutine tfinitrule(ispr,nrule)
      use tfstk
      implicit none
      type (sad_descriptor) kp
      integer*4 ispr,nrule,i,isp0
      do i=ispr+1,ispr+nrule*2,2
        kp=dtastk(i)
        if(ktfnonrealqd(kp) .and. ivstk2(2,i) .eq. 1)then
          isp0=isp
          call tfinitpat(isp0,kp)
          ivstk2(1,i)=isp0
          ivstk2(2,i)=isp
        endif
      enddo
      return
      end

      subroutine tfresetrule(ispr,nrule)
      use tfstk
      implicit none
      integer*4 ispr,nrule,i
      do i=ispr+1,ispr+nrule*2,2
        if(ktfpatqd(dtastk(i)) .or. ktflistqd(dtastk(i)))then
          call tfresetpat(dtastk(i))
        endif
      enddo
      return
      end

      recursive subroutine tfreplacestk(k,ispr,nrule,kx,all,rep,irtc)
      use tfstk
      use tfcode
      use iso_c_binding
      implicit none
      type (sad_descriptor) kp,k,kx,ki,k1,kir,ks,kd
      type (sad_list), pointer :: klir,kl,klx
      type (sad_pat), pointer :: pat
      integer*8 kair
      integer*4 irtc,i,m,isp1,ispr,nrule,isp0,isp2,
     $     itfmessageexp,mstk0,itfpmat,iop
      logical*4 rep,all,noreal,rep1,tfsameqd
      irtc=0
      noreal=.true.
      mstk0=mstk
      isp0=isp
      LOOP_I: do i=ispr+1,ispr+nrule*2,2
        kp=dtastk(i)
        noreal=noreal .and. ktfnonrealq(kp%k) .and.
     $       ivstk2(2,i) .eq. 0
        if(ktfnonrealqd(kp) .and. ivstk2(2,i) .ne. 0)then
          iop=iordless
          iordless=0
          m=itfpmat(k,kp)
          iordless=iop
          if(m .ge. 0)then
            kx=dtastk(i+1)
            isp2=isp
            call tfpvrulestk(ivstk2(1,i),ivstk2(2,i))
            if(isp .gt. isp2)then
              call tfreplacesymbolstk(kx,isp2,(isp-isp2)/2,kx,
     $             .false.,rep1,irtc)
            endif
            call tfresetpat(kp)
            isp=isp0
            mstk=mstk0
            rep=.true.
            return
          endif
          isp=isp0
          mstk=mstk0
        else
          if(tfsameqd(k,kp))then
            kx=dtastk(i+1)
            rep=.true.
            return
          endif
        endif
      enddo LOOP_I
      rep=.false.
      if(.not. all)then
        kx=k
        return
      endif
      if(ktflistqd(k,kl))then
        if(noreal .and. ktfreallistqo(kl))then
          ki=kl%dbody(0)
          call tfreplacestk(ki,ispr,nrule,k1,.true.,rep,irtc)
          if(irtc .ne. 0)then
            return
          endif
          if(.not. rep)then
            kx=k
            return
          endif
          m=kl%nl
          kx=kxavaloc(-1,m,klx)
          klx%dbody(0)=dtfcopy(k1)
          klx%body(1:m)=kl%body(1:m)
        else
          isp1=isp
          isp=isp+1
          call tfreplacestk(kl%dbody(0),ispr,nrule,dtastk(isp),
     $         .true.,rep,irtc)
          if(irtc .ne. 0)then
            isp=isp1
            return
          endif
          do i=1,kl%nl
            isp=isp+1
            call tfreplacestk(kl%dbody(i),ispr,nrule,kir,
     $           .true.,rep1,irtc)
            if(irtc .ne. 0)then
              isp=isp1
              return
            endif
            rep=rep .or. rep1
            dtastk(isp)=kir
            if(ktflistqd(kir,klir))then
              kair=ktfaddrd(kir)
              if(klir%head .eq. ktfoper+mtfnull)then
                if(ktastk(isp1+1) .ne. ktfoper+mtffun)then
                  rep=.true.
                  isp=isp-1
                  call tfgetllstkall(klir)
                endif
              endif
            endif
          enddo
          if(rep)then
            call tfcompose(isp1+1,ktastk(isp1+1),kx,irtc)
          else
            kx=k
          endif
          isp=isp1
        endif
      elseif(ktfpatqd(k,pat))then
        rep=.false.
        if(pat%sym%loc .ne. 0)then
          call tfreplacestk(pat%sym%alloc,ispr,nrule,ks,
     $         .false.,rep,irtc)
          if(irtc .ne. 0)then
            return
          endif
          if(rep)then
            if(ktfnonsymbolqd(ks))then
              irtc=itfmessageexp(999,'General::reppat',k)
              return
            endif
          endif
        else
          ks%k=0
        endif
        if(ktftype(pat%expr%k) .ne. ktfref)then
          call tfreplacestk(pat%expr,ispr,nrule,k1,
     $         .true.,rep1,irtc)
          if(irtc .ne. 0)then
            return
          endif
          rep=rep .or. rep1
        else
          k1=pat%expr
        endif
        kd=pat%default
        if(ktftype(kd%k) .ne. ktfref)then
          call tfreplacestk(kd,ispr,nrule,kd,.true.,rep1,irtc)
          if(irtc .ne. 0)then
            return
          endif
          rep=rep .or. rep1
        endif
        if(rep)then
          kx=kxpcopyss(k1,pat%head,ks,kd)
        else
          kx=k
        endif
      else
        kx=k
      endif
      return
      end

      subroutine tfreplacesymbolstk(k,ispr,nrule,kx,scope,rep,irtc)
      use tfstk
      implicit none
      type (sad_descriptor) k,kx
      integer*4 ispr,nrule,irtc,nrule1
      logical*4 scope,rep
      call tfsortsymbolstk(ispr,nrule,nrule1)
      call tfreplacesymbolstk1(k,ispr,nrule1,kx,scope,rep,irtc)
      return
      end

      recursive subroutine tfreplacesymbolstk1(k,ispr,nrule,kx,
     $     scope,rep,irtc)
      use tfstk
      use tfcode
      implicit none
      type (sad_descriptor) k,kx,kd,k1,ki,ks
      type (sad_pat), pointer :: pat
      type (sad_list), pointer :: kl,kli,klx
      integer*8 ka1,kas
      integer*4 irtc,i,m,isp1,j, ispr,nrule,itfmessageexp, id
      logical*4 rep,rep1,scope,tfmatchsymstk,tfsymbollistqo
      irtc=0
      rep=.false.
      kx=k
      if(ktflistqd(k,kl))then
        if(.not. tfsymbollistqo(kl))then
c     call tfdebugprint(ktflist+ktfaddr(k),'repsymstk',3)
          return
        endif
        m=kl%nl
        call tfreplacesymbolstk1(kl%dbody(0),ispr,nrule,k1,
     $       scope,rep,irtc)
        if(irtc .ne. 0)then
          return
        endif
        if(ktfreallistqo(kl))then
          if(rep)then
            kx=kxavaloc(-1,m,klx)
            klx%body(1:m)=kl%body(1:m)
            klx%dbody(0)=dtfcopy(k1)
          endif
        else
          isp1=isp
          isp=isp+1
          dtastk(isp)=k1
          if(ktfoperqd(k1))then
            ka1=ktfaddrd(k1)
            if(scope .and. ka1 .eq. mtffun)then
              if(m .eq. 2)then
                call tfreplacefunstk(kl,ispr,nrule,kx,rep1,irtc)
                rep=rep .or. rep1
                isp=isp1
                return
              endif
            else
              id=ilist(2,klist(ifunbase+ka1))
              if(id .eq. nfunif)then
                call tfreplaceifstk(kl,
     $               ispr,nrule,kx,scope,rep1,irtc)
                rep=rep .or. rep1
                isp=isp1
                return
              elseif(scope .and. id .eq. nfunwith)then
                if(kl%nl .eq. 2)then
                  call tfreplacewithstk(kl,
     $                 ispr,nrule,kx,rep1,irtc)
                  rep=rep .or. rep1
                  isp=isp1
                  return
                endif
              endif
            endif
          endif
          do i=1,m
c            call tfdebugprint(kl%body(i),'repsymstk',1)
            call tfreplacesymbolstk1(kl%dbody(i),ispr,nrule,ki,
     $         scope,rep1,irtc)
            if(irtc .ne. 0)then
              return
            endif
c            call tfdebugprint(ki,'==> ',1)
            rep=rep .or. rep1
            isp=isp+1
            dtastk(isp)=ki
            if(ktfsequenceq(ki%k,kli))then
              isp=isp-1
              call tfgetllstkall(kli)
            endif
          enddo
          if(rep)then
            call tfcompose(isp1+1,ktastk(isp1+1),kx,irtc)
          endif
          isp=isp1
        endif
        return
      elseif(ktfpatqd(k,pat))then
        if(pat%sym%loc .ne. 0)then
          ks=pat%sym%alloc
          kas=ktfaddr(ks)
          if(tfmatchsymstk(kas,ispr,nrule,j))then
            if(ktfnonsymbolq(ktastk(ivstk2(1,j)+1)))then
              irtc=itfmessageexp(999,'General::reppat',k)
              return
            endif
            ks=dtastk(ivstk2(1,j)+1)
            rep=.true.
          endif
        endif
        if(ktftype(pat%expr%k).ne. ktfref)then
          call tfreplacesymbolstk1(pat%expr,ispr,nrule,k1,
     $         scope,rep1,irtc)
          if(irtc .ne. 0)then
            return
          endif
          rep=rep .or. rep1
        else
          k1=pat%expr
        endif
        kd=pat%default
        if(ktftype(kd%k) .ne. ktfref)then
          call tfreplacesymbolstk1(kd,ispr,nrule,kd,scope,rep1,irtc)
          if(irtc .ne. 0)then
            return
          endif
          rep=rep .or. rep1
        endif
        if(rep)then
          kx=kxpcopyss(k1,pat%head,ks,kd)
        endif
        return
      elseif(ktfsymbolqd(k))then
c        call tfdebugprint(k,'repsymstk-symbol',1)
        if(tfmatchsymstk(ktfaddr(k),ispr,nrule,j))then
          kx=dtastk(ivstk2(1,j)+1)
c          if(ktfsymbolq(kx))then
c            call tfdebugprint(kx,'==> ',1)
c            write(*,*)'with ',ilist(2,ktfaddr(kx)-3)
c          endif
          rep=.true.
          return
        endif
      endif
      return
      end

      logical*4 function tfmatchsymstk(ka,ispr,nrule,j)
      use tfstk
      implicit none
      type (sad_symbol), pointer :: sym
      integer*8 ka
      integer*4 ispr,nrule,j
      logical*4 tfmatchsymstk1
      call loc_sym(ka,sym)
      tfmatchsymstk=tfmatchsymstk1(sym%loc,max(0,sym%gen),ispr,nrule,j)
      return
      end

      logical*4 function tfmatchsymstk1(loc,iag,ispr,nrule,j)
      use tfstk
      implicit none
      integer*8 loc
      integer*4 ispr,nrule,jm,jl,jh,iag,j
      jl=1
      jh=nrule
      do while (jh .ge. jl)
        jm=(jl+jh)/2
        j=ispr+jm*2-1
        if(loc .eq. ktastk2(j+1))then
          if(iag .eq. ivstk2(2,j))then
            tfmatchsymstk1=.true.
            return
          elseif(iag .lt. ivstk2(2,j))then
            jh=jm-1
          else
            jl=jm+1
          endif
        elseif(loc .lt. ktastk2(j+1))then
          jh=jm-1
        else
          jl=jm+1
        endif
      enddo
      tfmatchsymstk1=.false.
      return
      end

      subroutine tfsortsymbolstk(ispr,n,n1)
      use tfstk
      implicit none
      integer*4 ispr,n,i,isp1,j,n1,ig0,ig1
      integer*8 kai,kz0
      integer*8, parameter:: k32=2**32
      integer*8, allocatable :: kz(:),kg(:)
      integer*4, allocatable :: itab(:)
      if(n .eq. 1)then
        kai=ktfaddr(ktastk(ispr+1))
        ivstk2(1,ispr+1)=ispr+1
        ivstk2(2,ispr+1)=
     $       max(0,ilist(2,kai-1))
        ktastk2(ispr+2)=klist(kai)
        n1=1
      else
        allocate (kz(n),itab(n),kg(n))
        do i=1,n
          itab(i)=i
          kai=ktfaddr(ktastk(ispr+i*2-1))
          kz(i)=klist(kai)
          kg(i)=max(0,ilist(2,kai-1))*k32+i
        enddo
        call tfsorti(itab,kz,kg,n)
        isp1=ispr-1
        kz0=0
        ig0=0
        do i=1,n
          j=itab(i)
          ig1=int(kg(j)/k32)
          if(kz(j) .ne. kz0 .or. ig1 .ne. ig0)then
            kz0=kz(j)
            ig0=ig1
            isp1=isp1+2
            ivstk2(1,isp1)=ispr+j*2-1
            ivstk2(2,isp1)=ig0
            ktastk2(isp1+1)=kz0
          endif
        enddo
        n1=(isp1-ispr+1)/2
        deallocate(kz,itab,kg)
      endif
      return
      end

      recursive subroutine tfsorti(itab,iz,kg,n)
      implicit none
      integer*8 iz(n),kg(n)
      integer*4 n,itab(n),m,i1,i2,is,im,ip1,ip2
      if(n .le. 1)then
        return
      endif
      i1=itab(1)
      i2=itab(n)
      if(iz(i1) .gt. iz(i2) .or.
     $     iz(i1) .eq. iz(i2) .and. kg(i1) .gt. kg(i2))then
        is=i1
        i1=i2
        i2=is
      endif
      if(n .eq. 2)then
        itab(1)=i1
        itab(2)=i2
        return
      endif
      m=(n+1)/2
      im=itab(m)
      if(iz(i1) .lt. iz(im) .or.
     $     iz(i1) .eq. iz(im) .and. kg(i1) .lt. kg(im))then
        if(iz(im) .gt. iz(i2) .or.
     $     iz(im) .eq. iz(i2) .and. kg(im) .gt. kg(i2))then
          is=im
          im=i2
          i2=is
        endif
      else
        is=im
        im=i1
        i1=is
      endif
      itab(1)=i1
      itab(m)=im
      itab(n)=i2
      if(n .eq. 3)then
        return
      endif
      itab(m)=itab(2)
      itab(2)=im
      ip1=3
      ip2=n-1
      do while(ip1 .le. ip2)
        do while((iz(itab(ip1)) .lt. iz(im) .or.
     $       iz(itab(ip1)) .eq. iz(im) .and. kg(itab(ip1)) .lt. kg(im))
     $       .and. ip1 .le. ip2)
          ip1=ip1+1
        enddo
        do while((iz(im) .lt. iz(itab(ip2)) .or.
     $       iz(itab(ip2)) .eq. iz(im) .and. kg(im) .lt. kg(itab(ip2)))
     $       .and. ip1 .le. ip2)
          ip2=ip2-1
        enddo
        if(ip2 .gt. ip1)then
          is=itab(ip1)
          itab(ip1)=itab(ip2)
          itab(ip2)=is
          ip1=ip1+1
          ip2=ip2-1
        endif
      enddo
      ip1=ip1-1
      is=itab(ip1)
      itab(ip1)=im
      itab(2)=is
      call tfsorti(itab,iz,kg,ip1-1)
      call tfsorti(itab(ip1+1),iz,kg,n-ip1)
      return
      end

      subroutine tfpvrulestk(isp1,isp2)
      use tfstk
      use tfcode
      implicit none
      type (sad_pat), pointer :: pat
      integer*8 kp,kap,kx
      integer*4 i,isp1,isp2,ispb,ispe
      logical*4 rep
      do i=isp1+1,isp2-1,2
        kp=ktastk(i)
        kap=ktfaddr(kp)
        call loc_pat(kap,pat)
        do while(associated(pat%equiv))
          pat=>pat%equiv
        enddo
c 1      k2=klist(kap+2)
c        ka2=ktfaddr(k2)
c        kt2=k2-ka2
c        if(iand(ktfmask,klist(kap+2)) .eq. ktfpat)then
c          kap=ktfaddr(klist(kap+2))
c          go to 1
c        endif
        ispb=isp
        call tfgetstkstk(pat%value,rep)
        ispe=isp
        call tfsequence(ispb,ispe,kx)
        isp=ispb+1
        dtastk(isp)=pat%sym%alloc
        isp=isp+1
        ktastk(isp)=kx
      enddo
      return
      end

      subroutine tfreplaceifstk(list,ispr,nrule,kx,
     $     scope,rep,irtc)
      use tfstk
      implicit none
      type (sad_descriptor) kx,ki,kr
      type (sad_list) list
      type (sad_list), pointer :: klx
      integer*4 ispr,nrule,irtc,i,isp1,j
      logical*4 rep,rep1,rep2,scope
      irtc=0
      isp1=isp
      if(list%nl .eq. 0)then
        if(rep)then
          kx=kxaaloc(-1,0,klx)
          klx%head=ktfoper+ktfaddr(ktastk(isp1))
        else
          kx%k=ktflist+ksad_loc(list%head)
        endif
        return
      endif
      ki=list%dbody(1)
      if(ktfrealqd(ki) .or. ktfstringqd(ki) .or. ktfoperqd(ki))then
        isp=isp+1
        dtastk(isp)=ki
      else
        call tfreplacesymbolstk1(ki,ispr,nrule,kr,scope,rep1,irtc)
        if(irtc .ne. 0)then
          isp=isp1
          return
        endif
        call tfgetstkstk(kr,rep2) 
        rep=rep .or. rep2 .or. rep1
      endif
      if(isp .eq. isp1+1)then
        if(ktfrealq(ktastk(isp1+1)))then
          if(ktastk(isp1+1) .ne. 0)then
            i=2
          else
            i=3
          endif
        else
          i=0
        endif
      else
        rep=.true.
        i=0
      endif
      if(i .ne. 0)then
        rep=.true.
        j=isp+1
        if(i .le. list%nl)then
          ki=list%dbody(i)
          if(ktfrealqd(ki) .or. ktfstringqd(ki) .or. ktfoperqd(ki))then
            kx=ki
          else
            call tfreplacesymbolstk1(ki,ispr,nrule,kr,scope,rep1,irtc)
            if(irtc .ne. 0)then
              isp=isp1
              return
            endif
            call tfgetstkstk(kr,rep2) 
            rep=rep .or. rep1 .or. rep2
            if(j .le. isp)then
              kx=dtastk(j)
            else
              kx%k=ktfoper+mtfnull
            endif
          endif
        else
          kx%k=ktfoper+mtfnull
        endif
        return
      endif
      do i=2,list%nl
        ki=list%dbody(i)
        if(ktfrealqd(ki) .or. ktfstringqd(ki) .or. ktfoperqd(ki))then
          isp=isp+1
          dtastk(isp)=ki
        else
          call tfreplacesymbolstk1(ki,ispr,nrule,kr,scope,rep1,irtc)
          if(irtc .ne. 0)then
            isp=isp1
            return
          endif
          call tfgetstkstk(kr,rep2)
          rep=rep2 .or. rep .or. rep1
        endif
      enddo
      if(rep)then
        call tfcompose(isp1,ktastk(isp1),kx,irtc)
      else
        kx%k=ktflist+ksad_loc(list%head)
      endif
      return
      end

      subroutine tfreplacewithstk(list,ispr,nrule,kx,rep,irtc)
      use tfstk
      implicit none
      type (sad_descriptor) kx,k1,k2
      type (sad_list) list
      type (sad_list), pointer :: kl1,kli,klx,klx1
      integer*8 kai,ki,ki1,ka1,kai1,ki2,ksave
      integer*4 ispr,nrule,irtc,i, ispj,ispa,ispb
      logical*4 rep,rep1,tfmatchsymstk
      irtc=0
      ispa=isp
      k1=list%dbody(1)
      rep=.false.
      if(tflistqd(k1,kl1))then
        ktastk(ispa+1:ispa+nrule*2)=ktastk(ispr+1:ispr+nrule*2)
        ktastk2(ispa+1:ispa+nrule*2)=ktastk2(ispr+1:ispr+nrule*2)
c        do i=1,nrule*2
c          ktastk(ispa+i)=ktastk(ispr+i)
c          ktastk2(ispa+i)=ktastk(ivstkoffset+ispr+i)
c        enddo
        isp=isp+nrule*2
        ispb=isp
        ka1=ktfaddrd(k1)
        do i=1,kl1%nl
          ki=kl1%body(i)
          if(ktflistq(ki,kli))then
            kai=ktfaddr(ki)
            if((kli%head .eq. ktfoper+mtfset .or.
     $           kli%head .eq. ktfoper+mtfsetdelayed) .and.
     $           kli%nl .eq. 2)then
              ki1=kli%body(1)
              if(ktfsymbolq(ki1))then
                kai1=ktfaddr(ki1)
                if(tfmatchsymstk(kai1,ispa,nrule,ispj))then
                  ivstk2(2,ispj)=min(-ivstk2(2,ispj)-1,ivstk2(2,ispj))
                  call tfreplacesymbolstk1(kli%body(2),ispr,nrule,ki2,
     $                 .true.,rep1,irtc)
                  if(irtc .ne. 0)then
                    isp=ispa
                    return
                  endif
                  isp=isp+1
                  if(rep1)then
                    dtastk(isp)=kxadaloc(-1,2,klx1)
                    klx1%head=klist(kai)
                    klx1%body(1)=ktfcopy1(ki1)
                    klx1%body(2)=ktfcopy(ki2)
                    rep=.true.
                  else
                    ktastk(isp)=ki1
                  endif
                  cycle
                endif
              endif
            endif
          endif
          isp=isp+1
          call tfreplacesymbolstk1(ki,ispr,nrule,ktastk(isp),
     $         .true.,rep1,irtc)
          if(irtc .ne. 0)then
            isp=ispa
            return
          endif
          rep=rep .or. rep1
        enddo
        if(rep)then
          k1=kxmakelist(ispb)
        endif
        call tfreplacesymbolstk1(list%body(2),ispa,nrule,k2,
     $     .true.,rep1,irtc)
        if(irtc .ne. 0)then
          isp=ispa
          return
        endif
c        ilist(2,ktfaddr(k2)-3)=ior(ilist(2,ktfaddr(k2)-3),kmodsymbol)
        rep=rep .or. rep1
        if(rep)then
          kx=kxadaloc(-1,2,klx)
          klx%head=list%head
          klx%dbody(1)=dtfcopy1(k1)
          klx%dbody(2)=dtfcopy(k2)
        else
          kx%k=ktflist+ksad_loc(list%head)
        endif
      else
        ksave=list%head
        list%head=ktfoper+mtfhold
        call tfreplacesymbolstk1(ktflist+ksad_loc(list%head),ispa,nrule,
     $       kx,.true.,rep,irtc)
        if(irtc .eq. 0 .and. ktflistqd(kx,klx))then
          klx%head=ksave
        endif
        list%head=ksave
      endif
      isp=ispa
      return
      end

      subroutine tfreplacefunstk(list,ispr,nrule,kx,rep,irtc)
      use tfstk
      implicit none
      type (sad_descriptor) kx,k1
      type (sad_list) list
      type (sad_list), pointer :: kl1,klx
      integer*8 kai,ki,ka1,ksave
      integer*4 ispr,nrule,irtc,i,isp1,j,ispi
      logical*4 rep,rep1,rej,tfmatchsymstk1
      irtc=0
      isp1=isp
      k1=list%dbody(1)
      if(tflistqd(k1,kl1))then
        do i=1,kl1%nl
          ki=kl1%body(i)
          if(ktfsymbolq(ki))then
            kai=ktfaddr(ki)
            isp=isp+1
            ktastk(isp)=klist(kai)
            ivstk2(2,isp)=max(0,ilist(2,kai-1))
          endif
        enddo
      elseif(ktfsymbolqd(k1))then
        isp=isp+1
        ka1=ktfaddrd(k1)
        ktastk(isp)=klist(ka1)
        ivstk2(2,isp)=max(0,ilist(2,ka1-1))
      endif
      rej=.false.
      if(isp .gt. isp1)then
        r1: do j=isp1+1,isp
          if(tfmatchsymstk1(ktastk(j),ivstk(2,j),ispr,nrule,ispi))then
            ivstk2(2,ispi)=Min(-ivstk2(2,ispi)-1,ivstk2(2,ispi))
            rej=.true.
            cycle r1
          endif
        enddo r1
      endif
      ksave=list%head
      list%head=ktfoper+mtfhold
      call tfreplacesymbolstk1(ktflist+ksad_loc(list%head),ispr,nrule,
     $     kx,.true.,rep1,irtc)
      if(irtc .eq. 0 .and. ktflistqd(kx,klx))then
        klx%head=ksave
      endif
      list%head=ksave
      rep=rep .or. rep1
      if(rej)then
        do i=1,nrule
          ispi=ispr+i*2-1
          ivstk2(2,ispi)=max(-(ivstk2(2,ispi)+1),ivstk2(2,ispi))
        enddo
      endif
      isp=isp1
      return
      end

      subroutine tfreplacerepeated(k,kr,kx,all,eval,irtc)
      use tfstk
      implicit none
      type (sad_descriptor) k,kr,kx,k1
      integer*4 irtc
      logical*4 all,eval,tfsameqd
      kx=k
      k1%k=ktfref
      irtc=0
      do while(.true.)
        if(tfsameqd(k1,kx))then
          return
        endif
        k1=kx
        call tfreplace(k1,kr,kx,all,eval,.false.,irtc)
        if(irtc .ne. 0)then
          return
        endif
      enddo
      end

      subroutine tfgetoption(symbol,kr,kx,irtc)
      use tfstk
      implicit none
      type (sad_descriptor) kr,kx
      type (sad_list), pointer :: lr
      integer*4 irtc
      character*(*) symbol
      logical*4 rep
      if(tfruleqk(kr%k,lr))then
        call tfgetoption1(ktfsymbolz(symbol,len(symbol)),lr,kx,rep)
        irtc=0
        if(.not. rep)then
          kx%k=ktfref
        endif
      else
        irtc=-1
      endif
      return
      end

      recursive subroutine tfgetoption1(ka,list,kx,rep)
      use tfstk
      implicit none
      type (sad_descriptor) kx
      type (sad_list) list
      type (sad_list), pointer :: listi
      integer*8 ka
      integer*4 i
      logical*4 rep,tfsamesymbolqk
      rep=.false.
      if(list%head .eq. ktfoper+mtflist)then
        do i=1,list%nl
          call loc_list(ktfaddr(list%body(i)),listi)
          call tfgetoption1(ka,listi,kx,rep)
          if(rep)then
            return
          endif
        enddo
      elseif(ktfnonreallistqo(list))then
        if(ktfsymbolq(list%body(1)))then
          rep=tfsamesymbolqk(ka,list%body(1))
          if(rep)then
            kx=list%dbody(2)
          endif
        endif
      endif
      return
      end

      subroutine tfgetoptionstk(isp1,kaopt,optname,nopt,ispopt,irtc)
      use tfstk
      implicit none
      type (sad_list), pointer :: lri
      type (sad_descriptor) kaopt(nopt)
      integer*4 isp1,nopt,ispopt,i,j,isp0,irtc,lenw
      logical*4 rep
      character*(*) optname(nopt)
      isp0=isp
      if(kaopt(1)%k .eq. 0)then
        do i=1,nopt
          kaopt(i)=kxsymbolz(optname(i),lenw(optname(i)))
        enddo
      endif
      do i=isp0,isp1,-1
        if(.not. tfruleqk(ktastk(i)))then
          ispopt=i+1
          go to 1
        endif
      enddo
      ispopt=isp1
 1    irtc=0
      isp=isp0+nopt
      if(ispopt .gt. isp)then
        ktastk(isp0+1:isp0+nopt)=ktfref
        return
      endif
      LOOP_J: do j=1,nopt
        do i=ispopt,isp0
          call loc_list(ktfaddr(ktastk(i)),lri)
          call tfgetoption1(kaopt(j),lri,dtastk(isp0+j),rep)
          if(rep)then
            cycle LOOP_J
          endif
        enddo
        ktastk(isp0+j)=ktfref
      enddo LOOP_J
      return
      end

      subroutine tfoverride(isp1,kx,irtc)
      use tfstk
      implicit none
      type (sad_list), pointer :: kli
      integer*8 kx,ki,k1
      integer*4 isp1,irtc,isp0,isp2,n,itfmessage,isp3,isp4,i,j
      if(isp1 .eq. isp)then
        kx=kxnulll
        irtc=0
        return
      elseif(isp1+1 .eq. isp)then
        if(klist(isp) .eq. ktfoper+mtfnull)then
          kx=kxnulll
          irtc=0
          return
        endif
      endif
      isp=isp+1
      isp0=isp
      do i=isp1+1,isp0-1
        ki=ktastk(i)
        if(ktflistq(ki,kli))then
          k1=kli%head
          if(k1 .eq. ktfoper+mtflist)then
            call tfgetllstkall(kli)
          elseif(k1 .eq. ktfoper+mtfrule .or.
     $           k1 .eq. ktfoper+mtfruledelayed)then
            isp=isp+1
            ktastk(isp)=ki
          else
            go to 9000
          endif
        else
          isp=isp+1
          ktastk(isp)=ki
        endif
      enddo
      isp2=isp
      do i=isp0+1,isp2
        isp=isp+1
        if(ktflistq(ktastk(i),kli))then
          ktastk(isp)=kli%body(1)
        else
          ktastk(isp)=ktastk(i)
        endif
      enddo
      n=isp-isp2
      isp3=isp
      call tfsortl(klist(isp2-3),.false.,n,2,ktfref,.true.,irtc)
      if(irtc .ne. 0)then
        isp=isp0-1
        return
      endif
      isp4=isp
      do i=1,n
        j=int(ktastk(isp3+i))
        if(j .ne. 0 .and.
     $       ktastk(isp0+j) .ne. ktfoper+mtfnull)then
          isp=isp+1
          ktastk(isp)=ktastk(isp0+j)
        endif
      enddo
      kx=ktflist+ktfmakelist(isp4)
      isp=isp0-1
      irtc=0
      return
 9000 irtc=itfmessage(9,'General::wrongtype',
     $     '"List, Rule, Symbol, String, Real"')
      isp=isp0-1
      return
      end
