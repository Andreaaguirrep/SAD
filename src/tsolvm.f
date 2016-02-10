      subroutine tsolvm(a,b,x,n,m,l,ndim,ndimb,ndimx,
     $     epslon,svd)
      implicit none
      integer*4 itmax,n,m,ndim,ndimb,ndimx,l,kkk
      parameter (itmax=256)
      real*8 a(ndim,m),b(ndimb,l),x(ndimx,l),epslon
      real*8 v(0:m+n),anorm,enorm
      real*8 aa,f,g,s,r,w,u,h,xmin,z,vv,d,c,p,bb,y,an
      real*8 q,h1,h2,t,r1,r2,ra
      integer*4 lsep(m+n),i,j,k,mn,it,isep,ibegin,iend,ma,i1,i1mn,
     $     kk
      logical*4 svd
      mn=min(n,m)
      do 1 i=1,n
        v(i)=1.d0
1     continue
      do 2 i=1,m
        x(i,1)=1.d0
2     continue
      do 10 i=1,mn
        i1=i+1
        if(i .lt. n)then
          do 5110 j=i1,n
            if(abs(a(i,i)) .gt. abs(a(j,i)))then
              p=a(j,i)/a(i,i)
              h1=v(i)+v(j)*p**2
              q=v(j)*p/h1
              v(j)=v(i)*v(j)/h1
              v(i)=h1
              do 5120 k=i1,m
                a(j,k)=a(j,k)-p*a(i,k)
                a(i,k)=a(i,k)+q*a(j,k)
5120          continue
              a(j,i)=0.d0
              do k=1,l
                b(j,k)=b(j,k)-p*b(i,k)
                b(i,k)=b(i,k)+q*b(j,k)
              enddo
            elseif(a(j,i) .ne. 0.d0)then
              p=a(i,i)/a(j,i)
              h1=v(j)+v(i)*p**2
              q=v(i)*p/h1
              v(j)=v(i)*v(j)/h1
              v(i)=h1
              do 5130 k=i1,m
                aa=a(j,k)
                a(j,k)=p*aa-a(i,k)
                a(i,k)=aa-q*a(j,k)
5130          continue
              a(i,i)=a(j,i)
              a(j,i)=0.d0
              do k=1,l
                bb=b(j,k)
                b(j,k)=p*bb-b(i,k)
                b(i,k)=bb-q*b(j,k)
              enddo
            endif
5110      continue
        endif
        if(i1 .lt. m)then
          do 5210 j=i1+1,m
            r1=x(i1,1)*a(i,i1)
            r2=x(j ,1)*a(i,j )
            r=sign(abs(dcmplx(r1,r2)),r1)
            if(r .ne. 0.d0)then
              c=r1/r
              s=r2/r
              if(abs(c) .gt. abs(s))then
                a(i,j)=0.d0
                h1=x(i1,1)/c
                h2=x(j ,1)*c
                p=s*x(i1,1)/h2
                q=s*x(j ,1)/h1
                x(i1,1)=h1
                x(j ,1)=h2
                do 5220 k=i1,n
                  a(k,j )=a(k,j )-p*a(k,i1)
                  a(k,i1)=a(k,i1)+q*a(k,j )
5220            continue
              else
                a(i,i1)=a(i,j)
                a(i,j)=0.d0
                h1=x(j ,1)/s
                h2=x(i1,1)*s
                p=c*x(j ,1)/h2
                q=c*x(i1,1)/h1
                x(i1,1)=h1
                x(j ,1)=h2
                do 5221 k=i1,n
                  aa=a(k,j)
                  a(k,j )=p*aa-a(k,i1)
                  a(k,i1)=aa-q*a(k,j )
5221            continue
              endif
            else
              c=1.d0
              s=0.d0
            endif
            a(i,j)=s
C           if(j .lt. ndim+2)then
            if(j .lt. n+2)then
              a(j-1,i)=c
            else
              if(c .le. abs(s) .and. c .ne. 0.d0)then
                a(i,j)=sign(1.d0/c,s)
              endif
            endif
5210      continue
        endif
10    continue
      anorm=0.d0
      xmin=1.d38
      do 20 i=1,mn
        p=sqrt(abs(v(i)))
        v(i+mn)=x(i,1)
        a(i,i)=a(i,i)*p
        x(i,1)=a(i,i)*x(i,1)
        do k=1,l
          b(i,k)=b(i,k)*p
        enddo
        if(i .lt. m)then
          a(i,i+1)=a(i,i+1)*p
          v(i)=a(i,i+1)*x(i+1,1)
        else
          v(i)=0.d0
        endif
        an=abs(x(i,1))+abs(v(i))
        anorm=max(anorm,an)
        if(an .ne. 0.d0)then
          xmin=min(xmin,abs(x(i,1)))
        endif
20    continue
      enorm=anorm*epslon
      if(.not. svd .and. xmin .gt. enorm)then
        do 4010 i=mn+2,m
          do k=1,l
            x(i,k)=0.d0
          enddo
4010    continue
        r=abs(dcmplx(x(mn,1),v(mn)))
        if(r .ne. 0.d0)then
          w=1.d0/r
          d=x(mn,1)*w
          v(mn)=v(mn)*w
          do k=1,l
            b(mn,k)=b(mn,k)*w
            if(mn .lt. m)then
              x(mn+1,k)=v(mn)*b(mn,k)
            endif
            x(mn,k)=d*b(mn,k)
          enddo
          ma=m
        else
          ma=mn
          d=0.d0
          v(mn)=0.d0
          do k=1,l
            b(mn,k)=0.d0
            x(mn,k)=0.d0
            if(mn .lt. m)then
              x(mn+1,k)=0.d0
            endif
          enddo
        endif
        do 4020 i=mn-1,1,-1
          if(x(i,1) .ne. 0.d0)then
            p=v(i)*d
            ra=abs(x(i,1))+abs(v(i))
            r=(x(i,1)/ra)**2+((v(i)-p)/ra)*((v(i)+p)/ra)
            w=1.d0/sqrt(abs(r))/ra
            do k=1,l
              b(i,k)=(b(i,k)-p*b(i+1,k))*w
            enddo
            u=-p*w
            do 4030 kk=i+1,min(mn,ma-1)
              v(kk)=u*v(kk)
              do k=1,l
                x(kk+1,k)=x(kk+1,k)+b(i,k)*v(kk)
              enddo
 4030       continue
            v(i)=(v(i)-p*d)*w
            d=x(i,1)*w
            do k=1,l
              x(i+1,k)=x(i+1,k)+b(i,k)*v(i)
              x(i,k)=d*b(i,k)
            enddo
          else
            ma=i
            d=0.d0
            v(i)=0.d0
            do k=1,l
              b(i,k)=0.d0
              x(i,k)=0.d0
            enddo
          endif
4020    continue
        do 4040 i=min(mn,m-2),1,-1
          do 4050 j=m,i+2,-1
            s=a(i,j)
C           if(j .lt. ndim+2)then
            if(j .lt. n+2)then
              c=a(j-1,i)
            else
              if(abs(s) .gt. 1.d0)then
                c=abs(1.d0/s)
                s=sign(1.d0-c**2/(1.d0+sqrt((1.d0-c)*(1.d0+c))),s)
              else
                c=1.d0-s**2/(1.d0+sqrt((1.d0-s)*(1.d0+s)))
              endif
            endif
            do k=1,l
              aa=x(i+1,k)
              x(i+1,k)= c*aa-s*x(j,k)
              x(j  ,k)= s*aa+c*x(j,k)
            enddo
4050      continue
4040    continue
        return
      endif
      do 5301 i=mn+1,m
        v(i+mn)=x(i,1)
5301  continue
      do 5310 i=min(mn,m-2),1,-1
        i1=i+1
        i1mn=i1+mn
        do 5320 j=m,i+2,-1
          s=a(i,j)
C         if(j .lt. ndim+2)then
          if(j .lt. n+2)then
            c=a(j-1,i)
            a(j-1,i)=0.d0
          else
            if(abs(s) .gt. 1.d0)then
              c=abs(1.d0/s)
              s=sign(1.d0-c**2/(1.d0+sqrt((1.d0-c)*(1.d0+c))),s)
            else
              c=1.d0-s**2/(1.d0+sqrt((1.d0-s)*(1.d0+s)))
            endif
          endif
          if(abs(c) .gt. abs(s))then
            h1=v(i1mn)*c
            h2=v(j +mn)/c
            p=s*v(j +mn)/h1
            q=s*v(i1mn)/h2
            v(i1mn)=h1
            v(j +mn)=h2
            a(i,j)=q*a(i,i1)
            do 5330 k=i1,mn
              a(k,i1)=a(k,i1)-p*a(k,j )
              a(k,j )=a(k,j )+q*a(k,i1)
5330        continue
          else
            h1=v(j +mn)/s
            h2=v(i1mn)*s
            p=c*v(j +mn)/h2
            q=c*v(i1mn)/h1
            v(i1mn)=h1
            v(j +mn)=h2
            a(i,j )=a(i,i1)
            a(i,i1)=a(i,i1)*q
            do 5331 k=i1,mn
              aa=a(k,j)
              a(k,j )=p*aa+a(k,i1)
              a(k,i1)=q*a(k,j )-aa
5331        continue
          endif
5320    continue
5310  continue
      lsep(1)=1
      isep=1
      ibegin=1
      iend=mn
      do 1510 i=1,mn
        v(mn+i)=1.d0
1510  continue
      v(0)=0.d0
1002  if(v(iend) .ne. 0.d0)then
        f=v(iend)
        v(iend)=0.d0
        do 1110 i=iend,ibegin,-1
          if(abs(f)+abs(x(i,1)) .ne. abs(x(i,1)))then
            p=abs(dcmplx(x(i,1),f))
            vv=v(i-1)/p
            v(i-1)=vv*x(i,1)
            x(i  ,1)=p
            f=-vv*f
          else
            exit
          endif
1110    continue
      endif
      do3001: do while(.true.)
1001    if(ibegin .ge. iend)then
          isep=isep-1
          if(isep .le. 0)then
            exit
          endif
          iend=ibegin-1
          ibegin=lsep(isep)
          go to 1001
        endif
        do 1210 it=1,itmax
          if(x(iend,1) .eq. 0.d0)then
            iend=iend-1
            go to 1002
          endif
          do 1010 i=iend-1,ibegin,-1
            an=abs(x(i,1))+abs(x(i+1,1))
            if(abs(v(i)) .le. an*1.d-16)then
              v(i)=0.d0
              if(i .eq. iend-1)then
                iend=iend-1
              else
                isep=isep+1
                ibegin=i+1
                lsep(isep)=ibegin
              endif
              cycle do3001
            endif
 1010     continue
          if( .not. svd)then
            do1611: do kkk=1,1
              do 1610 i=iend,ibegin,-1
                if(abs(x(i,1)) .le. enorm)then
                  exit do1611
                endif
 1610         continue
              do 1710 i=iend,ibegin+1,-1
                r=0.d0
                s=0.d0
                do 1720 j=1,m
                  r=r+a(i,j)**2
                  s=s+a(i,j)*a(i-1,j)
 1720           continue
                if(r .ne. 0.d0)then
                  p=s/r
                  do 1730 j=1,m
                    a(i-1,j)=a(i-1,j)-p*a(i,j)
 1730             continue
                  do k=1,l
                    b(i-1,k)=b(i-1,k)-p*b(i,k)
                  enddo
                endif
                x(i,1)=sqrt(r)*v(i+mn)
                v(i-1)=0.d0
 1710         continue
              ibegin=iend
              cycle do3001
            enddo do1611
          endif
          w=x(ibegin,1)
          z=x(iend,1)
          y=x(iend-1,1)
          if(ibegin .lt. iend-1)then
            g=v(iend-2)
          else
            g=0.d0
          endif
          h=v(iend-1)
          f=((y-z)*(y+z)+(g-h)*(g+h))*.5d0
          if(w .eq. 0.d0)then
            f=0.d0
          else
            g=h*y
            y=f+sign(abs(dcmplx(f,g)),f)
            if(y .ne. 0.d0)then
              f=((w-z)*(w+z)-h**2+g**2/y)/w
            else
              f=((w-z)*(w+z)-h**2)/w
            endif
          endif
          g=v(ibegin)
          h=g
          do1221: do kkk=1,1
            do 1140 i=ibegin,iend-1
              i1=i+1
              z=abs(dcmplx(f,g))
              v(i-1)=z
              if(z .ne. 0.d0)then
                c=f/z
                s=g/z
              else
                x(i,1)=w
                v(i)=h
                exit do1221
              endif
              f= w*c+h*s
              g=-w*s+h*c
              h= x(i1,1)*s
              y= x(i1,1)*c
              z=abs(dcmplx(f,h))
              x(i,1)=z
              if(z .ne. 0.d0)then
                c=f/z
                s=h/z
              else
                v(i)=g
                x(i1,1)=y
                exit do1221
              endif
              f= c*g+s*y
              w=-s*g+c*y
              g=v(i1)*s
              h=v(i1)*c
              if(abs(c) .gt. abs(s))then
                h1=v(i+mn)/c
                h2=v(i1+mn)*c
                r=s*v(i+mn)/h2
                t=s*v(i1+mn)/h1
                v(i+mn)=h1
                v(i1+mn)=h2
                do 1150 k=1,m
                  a(i1,k)=a(i1,k)-r*a(i ,k)
                  a(i ,k)=a(i ,k)+t*a(i1,k)
 1150           continue
                do k=1,l
                  b(i1,k)=b(i1,k)-r*b(i,k)
                  b(i ,k)=b(i ,k)+t*b(i1,k)
                enddo
              else
                h1=v(i1+mn)/s
                h2=v(i+mn)*s
                r=c*v(i1+mn)/h2
                t=c*v(i+mn)/h1
                v(i+mn)=h1
                v(i1+mn)=h2
                do 1151 k=1,m
                  aa=a(i1,k)
                  a(i1,k)=r*aa-a(i ,k)
                  a(i ,k)=aa-t*a(i1,k)
 1151           continue
                do k=1,l
                  bb=b(i1,k)
                  b(i1,k)=r*bb-b(i,k)
                  b(i ,k)=bb-t*b(i1,k)
                enddo
              endif
 1140       continue
            v(iend-1)=f
            x(iend,1)=w
          enddo do1221
          v(ibegin-1)=0.d0
 1210   continue
        write(*,*)' TSOLVM convergence fail. ',iend
        iend=iend-1
        v(iend)=0.d0
      enddo do3001
      anorm=abs(x(1,1))
      do 3010 i=2,mn
        anorm=max(anorm,abs(x(i,1)))
3010  continue
      anorm=anorm*epslon
      do 3110 i=1,mn
        s=x(i,1)
        if(abs(s) .gt. anorm)then
          w=(v(i+mn)/s)**2
        else
          w=(s*v(i+mn)/anorm**2)**2
        endif
        do k=1,l
          b(i,k)=b(i,k)*w
        enddo
3110  continue
      do k=1,l
        do 3030 i=1,m
          s=a(1,i)*b(1,k)
          do 3040 j=2,mn
            s=s+a(j,i)*b(j,k)
 3040     continue
          x(i,k)=s
 3030   continue
      enddo
      return
      end
