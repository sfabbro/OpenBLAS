      REAL*8 function dmaxf(n,dx,incx)
c
c     finds the index of element having max. absolute value.
c     jack dongarra, linpack, 3/11/78.
c     modified 3/93 to return if incx .le. 0.
c     modified 12/3/93, array(1) declarations changed to array(*)
c
      double precision dx(*)
      integer i,incx,ix,n
c
      dmaxf = 0
      if( n.lt.1 .or. incx.le.0 ) return

      if(incx.eq.1)go to 20
c
c        code for increment not equal to 1
c
      ix = 1
      dmaxf = dx(1)
      ix = ix + incx
      do 10 i = 2,n
         if(dx(ix).le.dmaxf) go to 5
         dmaxf = dx(ix)
    5    ix = ix + incx
   10 continue
      return
c
c        code for increment equal to 1
c
   20 dmaxf = dx(1)
      do 30 i = 2,n
         if(dx(i).le.dmaxf) go to 30
         dmaxf = dx(i)
   30 continue
      return
      end
