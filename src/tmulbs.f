      subroutine tmulbs(beam,trans1,poldiv,beamr)
      use tfstk
      implicit none
      include 'inc/TMACRO1.inc'
      integer*4 j
      real*8 beam(42),trans1(6,12),s(6,6)
      logical*4 poldiv,beamr
c     ia(m,n)=((m+n+abs(m-n))**2+2*(m+n)-6*abs(m-n))/8
c     data ia/ 1, 2, 4, 7,11,16,
c    1         2, 3, 5, 8,12,17,
c    1         4, 5, 6, 9,13,18,
c    1         7, 8, 9,10,14,19,
c    1        11,12,13,14,15,20,
c    1        16,17,18,19,20,21/
      if(irad .lt. 12)then
        if(calpol .and. poldiv)then
          npelm=npelm+1
        endif
        return
      endif
      if(calpol .and. poldiv)then
        ipelm=ipelm+1
        if(ipelm .le. npelm)then
          call tmov(trans1,rlist(ipoltr+(ipelm-1)*36),36)
        endif
      endif
      do j=1,6
        s(1,j)=trans1(j,1)*beam(1) +trans1(j,2)*beam(2)
     1        +trans1(j,3)*beam(4) +trans1(j,4)*beam(7)
     1        +trans1(j,5)*beam(11)+trans1(j,6)*beam(16)
        s(2,j)=trans1(j,1)*beam(2) +trans1(j,2)*beam(3)
     1        +trans1(j,3)*beam(5) +trans1(j,4)*beam(8)
     1        +trans1(j,5)*beam(12)+trans1(j,6)*beam(17)
        s(3,j)=trans1(j,1)*beam(4) +trans1(j,2)*beam(5)
     1        +trans1(j,3)*beam(6) +trans1(j,4)*beam(9)
     1        +trans1(j,5)*beam(13)+trans1(j,6)*beam(18)
        s(4,j)=trans1(j,1)*beam(7) +trans1(j,2)*beam(8)
     1        +trans1(j,3)*beam(9) +trans1(j,4)*beam(10)
     1        +trans1(j,5)*beam(14)+trans1(j,6)*beam(19)
        s(5,j)=trans1(j,1)*beam(11)+trans1(j,2)*beam(12)
     1        +trans1(j,3)*beam(13)+trans1(j,4)*beam(14)
     1        +trans1(j,5)*beam(15)+trans1(j,6)*beam(20)
        s(6,j)=trans1(j,1)*beam(16)+trans1(j,2)*beam(17)
     1        +trans1(j,3)*beam(18)+trans1(j,4)*beam(19)
     1        +trans1(j,5)*beam(20)+trans1(j,6)*beam(21)
      enddo
        beam(1)=s(1,1)*trans1(1,1)+s(2,1)*trans1(1,2)
     1         +s(3,1)*trans1(1,3)+s(4,1)*trans1(1,4)
     1         +s(5,1)*trans1(1,5)+s(6,1)*trans1(1,6)
        beam(2)=s(1,1)*trans1(2,1)+s(2,1)*trans1(2,2)
     1         +s(3,1)*trans1(2,3)+s(4,1)*trans1(2,4)
     1         +s(5,1)*trans1(2,5)+s(6,1)*trans1(2,6)
        beam(3)=s(1,2)*trans1(2,1)+s(2,2)*trans1(2,2)
     1         +s(3,2)*trans1(2,3)+s(4,2)*trans1(2,4)
     1         +s(5,2)*trans1(2,5)+s(6,2)*trans1(2,6)
        beam(4)=s(1,1)*trans1(3,1)+s(2,1)*trans1(3,2)
     1         +s(3,1)*trans1(3,3)+s(4,1)*trans1(3,4)
     1         +s(5,1)*trans1(3,5)+s(6,1)*trans1(3,6)
        beam(5)=s(1,2)*trans1(3,1)+s(2,2)*trans1(3,2)
     1         +s(3,2)*trans1(3,3)+s(4,2)*trans1(3,4)
     1         +s(5,2)*trans1(3,5)+s(6,2)*trans1(3,6)
        beam(6)=s(1,3)*trans1(3,1)+s(2,3)*trans1(3,2)
     1         +s(3,3)*trans1(3,3)+s(4,3)*trans1(3,4)
     1         +s(5,3)*trans1(3,5)+s(6,3)*trans1(3,6)
        beam(7)=s(1,1)*trans1(4,1)+s(2,1)*trans1(4,2)
     1         +s(3,1)*trans1(4,3)+s(4,1)*trans1(4,4)
     1         +s(5,1)*trans1(4,5)+s(6,1)*trans1(4,6)
        beam(8)=s(1,2)*trans1(4,1)+s(2,2)*trans1(4,2)
     1         +s(3,2)*trans1(4,3)+s(4,2)*trans1(4,4)
     1         +s(5,2)*trans1(4,5)+s(6,2)*trans1(4,6)
        beam(9)=s(1,3)*trans1(4,1)+s(2,3)*trans1(4,2)
     1         +s(3,3)*trans1(4,3)+s(4,3)*trans1(4,4)
     1         +s(5,3)*trans1(4,5)+s(6,3)*trans1(4,6)
       beam(10)=s(1,4)*trans1(4,1)+s(2,4)*trans1(4,2)
     1         +s(3,4)*trans1(4,3)+s(4,4)*trans1(4,4)
     1         +s(5,4)*trans1(4,5)+s(6,4)*trans1(4,6)
       beam(11)=s(1,1)*trans1(5,1)+s(2,1)*trans1(5,2)
     1         +s(3,1)*trans1(5,3)+s(4,1)*trans1(5,4)
     1         +s(5,1)*trans1(5,5)+s(6,1)*trans1(5,6)
       beam(12)=s(1,2)*trans1(5,1)+s(2,2)*trans1(5,2)
     1         +s(3,2)*trans1(5,3)+s(4,2)*trans1(5,4)
     1         +s(5,2)*trans1(5,5)+s(6,2)*trans1(5,6)
       beam(13)=s(1,3)*trans1(5,1)+s(2,3)*trans1(5,2)
     1         +s(3,3)*trans1(5,3)+s(4,3)*trans1(5,4)
     1         +s(5,3)*trans1(5,5)+s(6,3)*trans1(5,6)
       beam(14)=s(1,4)*trans1(5,1)+s(2,4)*trans1(5,2)
     1         +s(3,4)*trans1(5,3)+s(4,4)*trans1(5,4)
     1         +s(5,4)*trans1(5,5)+s(6,4)*trans1(5,6)
       beam(15)=s(1,5)*trans1(5,1)+s(2,5)*trans1(5,2)
     1         +s(3,5)*trans1(5,3)+s(4,5)*trans1(5,4)
     1         +s(5,5)*trans1(5,5)+s(6,5)*trans1(5,6)
       beam(16)=s(1,1)*trans1(6,1)+s(2,1)*trans1(6,2)
     1         +s(3,1)*trans1(6,3)+s(4,1)*trans1(6,4)
     1         +s(5,1)*trans1(6,5)+s(6,1)*trans1(6,6)
       beam(17)=s(1,2)*trans1(6,1)+s(2,2)*trans1(6,2)
     1         +s(3,2)*trans1(6,3)+s(4,2)*trans1(6,4)
     1         +s(5,2)*trans1(6,5)+s(6,2)*trans1(6,6)
       beam(18)=s(1,3)*trans1(6,1)+s(2,3)*trans1(6,2)
     1         +s(3,3)*trans1(6,3)+s(4,3)*trans1(6,4)
     1         +s(5,3)*trans1(6,5)+s(6,3)*trans1(6,6)
       beam(19)=s(1,4)*trans1(6,1)+s(2,4)*trans1(6,2)
     1         +s(3,4)*trans1(6,3)+s(4,4)*trans1(6,4)
     1         +s(5,4)*trans1(6,5)+s(6,4)*trans1(6,6)
       beam(20)=s(1,5)*trans1(6,1)+s(2,5)*trans1(6,2)
     1         +s(3,5)*trans1(6,3)+s(4,5)*trans1(6,4)
     1         +s(5,5)*trans1(6,5)+s(6,5)*trans1(6,6)
       beam(21)=s(1,6)*trans1(6,1)+s(2,6)*trans1(6,2)
     1         +s(3,6)*trans1(6,3)+s(4,6)*trans1(6,4)
     1         +s(5,6)*trans1(6,5)+s(6,6)*trans1(6,6)
       if(calint .and. beamr)then
         do j=1,6
           s(1,j)=trans1(j,1)*beam(21+1) +trans1(j,2)*beam(21+2)
     1          +trans1(j,3)*beam(21+4) +trans1(j,4)*beam(21+7)
     1          +trans1(j,5)*beam(21+11)+trans1(j,6)*beam(21+16)
           s(2,j)=trans1(j,1)*beam(21+2) +trans1(j,2)*beam(21+3)
     1          +trans1(j,3)*beam(21+5) +trans1(j,4)*beam(21+8)
     1          +trans1(j,5)*beam(21+12)+trans1(j,6)*beam(21+17)
           s(3,j)=trans1(j,1)*beam(21+4) +trans1(j,2)*beam(21+5)
     1          +trans1(j,3)*beam(21+6) +trans1(j,4)*beam(21+9)
     1          +trans1(j,5)*beam(21+13)+trans1(j,6)*beam(21+18)
           s(4,j)=trans1(j,1)*beam(21+7) +trans1(j,2)*beam(21+8)
     1          +trans1(j,3)*beam(21+9) +trans1(j,4)*beam(21+10)
     1          +trans1(j,5)*beam(21+14)+trans1(j,6)*beam(21+19)
           s(5,j)=trans1(j,1)*beam(21+11)+trans1(j,2)*beam(21+12)
     1          +trans1(j,3)*beam(21+13)+trans1(j,4)*beam(21+14)
     1          +trans1(j,5)*beam(21+15)+trans1(j,6)*beam(21+20)
           s(6,j)=trans1(j,1)*beam(21+16)+trans1(j,2)*beam(21+17)
     1          +trans1(j,3)*beam(21+18)+trans1(j,4)*beam(21+19)
     1          +trans1(j,5)*beam(21+20)+trans1(j,6)*beam(21+21)
         enddo
         beam(21+1)=s(1,1)*trans1(1,1)+s(2,1)*trans1(1,2)
     1        +s(3,1)*trans1(1,3)+s(4,1)*trans1(1,4)
     1        +s(5,1)*trans1(1,5)+s(6,1)*trans1(1,6)
         beam(21+2)=s(1,1)*trans1(2,1)+s(2,1)*trans1(2,2)
     1        +s(3,1)*trans1(2,3)+s(4,1)*trans1(2,4)
     1        +s(5,1)*trans1(2,5)+s(6,1)*trans1(2,6)
         beam(21+3)=s(1,2)*trans1(2,1)+s(2,2)*trans1(2,2)
     1        +s(3,2)*trans1(2,3)+s(4,2)*trans1(2,4)
     1        +s(5,2)*trans1(2,5)+s(6,2)*trans1(2,6)
         beam(21+4)=s(1,1)*trans1(3,1)+s(2,1)*trans1(3,2)
     1        +s(3,1)*trans1(3,3)+s(4,1)*trans1(3,4)
     1        +s(5,1)*trans1(3,5)+s(6,1)*trans1(3,6)
         beam(21+5)=s(1,2)*trans1(3,1)+s(2,2)*trans1(3,2)
     1        +s(3,2)*trans1(3,3)+s(4,2)*trans1(3,4)
     1        +s(5,2)*trans1(3,5)+s(6,2)*trans1(3,6)
         beam(21+6)=s(1,3)*trans1(3,1)+s(2,3)*trans1(3,2)
     1        +s(3,3)*trans1(3,3)+s(4,3)*trans1(3,4)
     1        +s(5,3)*trans1(3,5)+s(6,3)*trans1(3,6)
         beam(21+7)=s(1,1)*trans1(4,1)+s(2,1)*trans1(4,2)
     1        +s(3,1)*trans1(4,3)+s(4,1)*trans1(4,4)
     1        +s(5,1)*trans1(4,5)+s(6,1)*trans1(4,6)
         beam(21+8)=s(1,2)*trans1(4,1)+s(2,2)*trans1(4,2)
     1        +s(3,2)*trans1(4,3)+s(4,2)*trans1(4,4)
     1        +s(5,2)*trans1(4,5)+s(6,2)*trans1(4,6)
         beam(21+9)=s(1,3)*trans1(4,1)+s(2,3)*trans1(4,2)
     1        +s(3,3)*trans1(4,3)+s(4,3)*trans1(4,4)
     1        +s(5,3)*trans1(4,5)+s(6,3)*trans1(4,6)
         beam(21+10)=s(1,4)*trans1(4,1)+s(2,4)*trans1(4,2)
     1        +s(3,4)*trans1(4,3)+s(4,4)*trans1(4,4)
     1        +s(5,4)*trans1(4,5)+s(6,4)*trans1(4,6)
         beam(21+11)=s(1,1)*trans1(5,1)+s(2,1)*trans1(5,2)
     1        +s(3,1)*trans1(5,3)+s(4,1)*trans1(5,4)
     1        +s(5,1)*trans1(5,5)+s(6,1)*trans1(5,6)
         beam(21+12)=s(1,2)*trans1(5,1)+s(2,2)*trans1(5,2)
     1        +s(3,2)*trans1(5,3)+s(4,2)*trans1(5,4)
     1        +s(5,2)*trans1(5,5)+s(6,2)*trans1(5,6)
         beam(21+13)=s(1,3)*trans1(5,1)+s(2,3)*trans1(5,2)
     1        +s(3,3)*trans1(5,3)+s(4,3)*trans1(5,4)
     1        +s(5,3)*trans1(5,5)+s(6,3)*trans1(5,6)
         beam(21+14)=s(1,4)*trans1(5,1)+s(2,4)*trans1(5,2)
     1        +s(3,4)*trans1(5,3)+s(4,4)*trans1(5,4)
     1        +s(5,4)*trans1(5,5)+s(6,4)*trans1(5,6)
         beam(21+15)=s(1,5)*trans1(5,1)+s(2,5)*trans1(5,2)
     1        +s(3,5)*trans1(5,3)+s(4,5)*trans1(5,4)
     1        +s(5,5)*trans1(5,5)+s(6,5)*trans1(5,6)
         beam(21+16)=s(1,1)*trans1(6,1)+s(2,1)*trans1(6,2)
     1        +s(3,1)*trans1(6,3)+s(4,1)*trans1(6,4)
     1        +s(5,1)*trans1(6,5)+s(6,1)*trans1(6,6)
         beam(21+17)=s(1,2)*trans1(6,1)+s(2,2)*trans1(6,2)
     1        +s(3,2)*trans1(6,3)+s(4,2)*trans1(6,4)
     1        +s(5,2)*trans1(6,5)+s(6,2)*trans1(6,6)
         beam(21+18)=s(1,3)*trans1(6,1)+s(2,3)*trans1(6,2)
     1        +s(3,3)*trans1(6,3)+s(4,3)*trans1(6,4)
     1        +s(5,3)*trans1(6,5)+s(6,3)*trans1(6,6)
         beam(21+19)=s(1,4)*trans1(6,1)+s(2,4)*trans1(6,2)
     1        +s(3,4)*trans1(6,3)+s(4,4)*trans1(6,4)
     1        +s(5,4)*trans1(6,5)+s(6,4)*trans1(6,6)
         beam(21+20)=s(1,5)*trans1(6,1)+s(2,5)*trans1(6,2)
     1        +s(3,5)*trans1(6,3)+s(4,5)*trans1(6,4)
     1        +s(5,5)*trans1(6,5)+s(6,5)*trans1(6,6)
         beam(21+21)=s(1,6)*trans1(6,1)+s(2,6)*trans1(6,2)
     1        +s(3,6)*trans1(6,3)+s(4,6)*trans1(6,4)
     1        +s(5,6)*trans1(6,5)+s(6,6)*trans1(6,6)
       endif
       return
       end
