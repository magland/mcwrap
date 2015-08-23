#### main

!
!
! This file was auto-generated by MCWRAP
! https://github.com/magland/mcwrap
!
! You should not edit this file.
! You might not even want to read it.
! 
! 

#include "fintrf.h"

!====================================================================
!====================================================================

!     Gateway routine
subroutine mexFunction(nlhs, plhs, nrhs, prhs)

!     Declarations
      implicit none
      integer ii,jj
      mwSize numdims
      integer*4 dims(100)
      integer*4, ALLOCATABLE :: dims2(:)
      character*120 debug_line

!     mexFunction arguments:
      mwPointer plhs(*), prhs(*)
      integer nlhs, nrhs

!     Function declarations:
      mwPointer mxGetPr, mxGetPi
      mwPointer mxCreateNumericArray
      integer*4 mxClassIDFromClassName
      integer mxIsNumeric
      mwSize mxGetNumberOfDimensions
      mwPointer mxGetDimensions
      integer mcwrap_size

!CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
!     Declare inputs:
@foreach input
    @if $ptype$=int
        ^template fdeclare_input_int
    @end if $ptype$=int
    @if $ptype$=double
        ^template fdeclare_input_double
    @end if $ptype$=double
    @if $ptype$=double*
        ^template fdeclare_input_double_array$underscore_complex$
    @end if $ptype$=double*
@end foreach input

!     Declare outputs:
@foreach output
    @if $ptype$=int
        ^template fdeclare_output_int
    @end if $ptype$=int
    @if $ptype$=double
        ^template fdeclare_output_double
    @end if $ptype$=double
    @if $ptype$=double*
        ^template fdeclare_output_double_array$underscore_complex$
    @end if $ptype$=double*
    @if $ptype$=int*
        ^template fdeclare_output_int_array
    @end if $ptype$=int*
@end foreach output

!     Declare set inputs:
@foreach set_input
    @if $ptype$=int
        ^template fdeclare_set_input_int
    @end if $ptype$=int
    @if $ptype$=double
        ^template fdeclare_set_input_double
    @end if $ptype$=double
@end foreach set_input

      !call mexPrintf('test A'//char(10))
!-----Check the number of inputs/outputs
      if (nlhs==0) then
          nlhs=1
      end if
      if(nrhs .ne. $num_inputs$) then
         call mexErrMsgIdAndTxt ('MCWRAP:IO','Incorrect number of inputs') 
      elseif(nlhs .gt. $num_outputs$) then
         call mexErrMsgIdAndTxt ('MCWRAP:IO','Too many outputs.')
      endif


      !call mexPrintf('test A.2'//char(10))
!-----Setup the set inputs
@foreach set_input
    @if $ptype$=int
        ^template fsetup_set_input_int
    @end if $ptype$=int
    @if $ptype$=double
        ^template fsetup_set_input_double
    @end if $ptype$=double
@end foreach set_input

    
      !call mexPrintf('test B'//char(10))
!-----Setup the inputs
@foreach input
    @if $ptype$=int
        ^template fsetup_input_int
    @end if $ptype$=int
    @if $ptype$=double
        ^template fsetup_input_double
    @end if $ptype$=double
    @if $ptype$=double*
        ^template fsetup_input_double_array$underscore_complex$
    @end if $ptype$=double*
    @if $ptype$=int*
        ^template fsetup_input_int_array
    @end if $ptype$=int*
@end foreach input
    
      !call mexPrintf('test C'//char(10))
!-----Setup the outputs
@foreach output
    @if $ptype$=int
        ^template fsetup_output_int
    @end if $ptype$=int
    @if $ptype$=double
        ^template fsetup_output_double
    @end if $ptype$=double
    @if $ptype$=double*
        ^template fsetup_output_double_array$underscore_complex$
    @end if $ptype$=double*
    @if $ptype$=int*
        ^template fsetup_output_int_array
    @end if $ptype$=int*
@end foreach output

    
      !call mexPrintf('test D'//char(10))
!-----Run the subroutine
        call $function_name$( &
$arguments$
        );
   
      !call mexPrintf('test E'//char(10))
!-----Free the inputs
@foreach input
    @if $ptype$=double*
        ^template ffree_input_double_array$underscore_complex$
    @end if $ptype$=double*
    @if $ptype$=int*
        ^template ffree_input_int_array
    @end if $ptype$=int*
@end foreach input

      !call mexPrintf('test F'//char(10))
!-----Set the outputs
@foreach output
    @if $ptype$=int
        ^template fset_output_int
    @end if $ptype$=int
    @if $ptype$=double
        ^template fset_output_double
    @end if $ptype$=double
    @if $ptype$=double*
        ^template fset_output_double_array$underscore_complex$
    @end if $ptype$=double*
    @if $ptype$=int*
        ^template fset_output_int_array
    @end if $ptype$=int*
@end foreach output

      !call mexPrintf('test G'//char(10))

!----- We are done -----!

        return
        end

    function mcwrap_size(X,j) result(ret)
        implicit none !important!!
        mwPointer X
        integer j
        integer*4 ret
        mwSize numdims
        integer*4 dims(100)
        mwSize mxGetNumberOfDimensions
        mwPointer mxGetDimensions
        
        numdims=mxGetNumberOfDimensions(X)
        if ((j .lt. 1) .or. (j .gt. numdims)) then
            ret=1
            return
        end if
        call mxCopyPtrToInteger4(mxGetDimensions(X),dims,numdims)
        ret=dims(j)
    end function mcwrap_size

#### fdeclare_set_input_int

        !$pname$
        integer input_$pname$

#### fdeclare_set_input_double

        !$pname$
        real*8 input_$pname$


#### fdeclare_input_double

        !$pname$
        mwPointer p_input_$pname$
        real*8 input_$pname$

#### fdeclare_input_double_array

        !$pname$
        mwPointer p_input_$pname$
        real*8, ALLOCATABLE :: input_$pname$(:)

#### fdeclare_input_double_array_complex

        !$pname$
        mwPointer p_input_$pname$_re
        mwPointer p_input_$pname$_im
        real*8, ALLOCATABLE :: input_$pname$(:)
        real*8, ALLOCATABLE :: input_$pname$_re(:)
        real*8, ALLOCATABLE :: input_$pname$_im(:)

#### fdeclare_input_int_array

        !$pname$
        mwPointer p_input_$pname$
        integer, ALLOCATABLE :: input_$pname$(:)
        real*8, ALLOCATABLE :: input_$pname$_double(:)

#### fdeclare_input_int

        !$pname$
        mwPointer p_input_$pname$
        Integer input_$pname$
        real*8 input_$pname$_double

#### fdeclare_output_double

        !$pname$
!CC Scalar output not yet supported!

#### fdeclare_output_double_array

        !$pname$
        mwPointer p_output_$pname$
        real*8, ALLOCATABLE :: output_$pname$(:)

#### fdeclare_output_double_array_complex

        !$pname$
        mwPointer p_output_$pname$_re
        mwPointer p_output_$pname$_im
        real*8, ALLOCATABLE :: output_$pname$(:)
        real*8, ALLOCATABLE :: output_$pname$_re(:)
        real*8, ALLOCATABLE :: output_$pname$_im(:)

#### fdeclare_output_int_array

        !$pname$
        mwPointer p_output_$pname$
        integer, ALLOCATABLE :: output_$pname$(:)
        real*8, ALLOCATABLE :: output_$pname$_double(:)

#### fdeclare_output_int

        !$pname$
!CC Scalar output not yet supported!

#### ffree_input_double_array

        !$pname$
        DEALLOCATE(input_$pname$)

#### ffree_input_double_array_complex

        !$pname$
        DEALLOCATE(input_$pname$)
        DEALLOCATE(input_$pname$_re)
        DEALLOCATE(input_$pname$_im)

#### ffree_input_int_array

        !$pname$
        DEALLOCATE(input_$pname$)
        DEALLOCATE(input_$pname$_double)

#### fset_output_double

        !$pname$
!CC Scalar outputs not yet supported

#### fset_output_double_array

        !$pname$
        if ($pindex$ .LE. nlhs) then
            call mxCopyReal8ToPtr(output_$pname$,p_output_$pname$,int($total_size$))
        end if
        DEALLOCATE(output_$pname$)

#### fset_output_double_array_complex

        !$pname$
        if ($pindex$ .LE. nlhs) then
            do ii=1,$total_size$
                output_$pname$_re(ii)=output_$pname$(1+(ii-1)*2)
                output_$pname$_im(ii)=output_$pname$(1+(ii-1)*2+1)
            end do
            call mxCopyReal8ToPtr(output_$pname$_re,p_output_$pname$_re,int($total_size$))
            call mxCopyReal8ToPtr(output_$pname$_im,p_output_$pname$_im,int($total_size$))
        end if
        DEALLOCATE(output_$pname$)
        DEALLOCATE(output_$pname$_re)
        DEALLOCATE(output_$pname$_im)

#### fset_output_int_array

        !$pname$
        if ($pindex$ .LE. nlhs) then
            do ii=1,$total_size$
                output_$pname$_double(ii)=output_$pname$(ii)
            end do
            call mxCopyReal8ToPtr(output_$pname$_double,p_output_$pname$,int($total_size$))
        end if
        DEALLOCATE(output_$pname$)
        DEALLOCATE(output_$pname$_double)

#### fset_output_int

!CC Scalar outputs not yet supported

#### fsetup_input_double

        !$pname$
        p_input_$pname$=mxGetPr(prhs($pindex$));
        call mxCopyPtrToReal8(p_input_$pname$,input_$pname$,1)

#### fsetup_input_int

        !$pname$
        p_input_$pname$=mxGetPr(prhs($pindex$));
        call mxCopyPtrToReal8(p_input_$pname$,input_$pname$_double,1)
        input_$pname$=int(input_$pname$_double)

#### fsetup_input_double_array

        !$pname$
        ^template fsetup_check_dimensions
        p_input_$pname$=mxGetPr(prhs($pindex$));
        ALLOCATE(input_$pname$($total_size$))
        call mxCopyPtrToReal8(p_input_$pname$,input_$pname$,int($total_size$))
        
#### fsetup_input_double_array_complex

        !$pname$
        ^template fsetup_check_dimensions
        p_input_$pname$_re=mxGetPr(prhs($pindex$));
        p_input_$pname$_im=mxGetPi(prhs($pindex$));
        ALLOCATE(input_$pname$($total_size$*2))
        ALLOCATE(input_$pname$_re($total_size$))
        ALLOCATE(input_$pname$_im($total_size$))
        call mxCopyPtrToReal8(p_input_$pname$_re,input_$pname$_re,int($total_size$))
        if (p_input_$pname$_im .NE. 0) then
            call mxCopyPtrToReal8(p_input_$pname$_im,input_$pname$_im,int($total_size$))
        end if
        do ii=1,$total_size$
            input_$pname$(1+(ii-1)*2)=input_$pname$_re(ii)
            if (p_input_$pname$_im .NE. 0) then
            input_$pname$(1+(ii-1)*2+1)=input_$pname$_im(ii)
            else
            input_$pname$(1+(ii-1)*2+1)=0    
            end if
        end do

#### fsetup_input_int_array

        !$pname$
        ^template fsetup_check_dimensions
        p_input_$pname$=mxGetPr(prhs($pindex$));
        ALLOCATE(input_$pname$($total_size$))
        ALLOCATE(input_$pname$_double($total_size$))
        call mxCopyPtrToReal8(p_input_$pname$,input_$pname$_double,int($total_size$))
        do ii=1,$total_size$
            input_$pname$(ii)=int(input_$pname$_double(ii))
        end do
        

#### fsetup_check_dimensions

        !Check that we have the correct dimensions!
        numdims=mxGetNumberOfDimensions(prhs($pindex$))
        if (numdims .gt. $numdims$) then
          call mexErrMsgTxt('Incorrect number of dimensions in input: $pname$')
        end if
        call mxCopyPtrToInteger4(mxGetDimensions(prhs($pindex$)),dims,numdims)
        ALLOCATE(dims2($numdims$))
        dims2=(/ $dimensions$ /)
        do ii=1,$numdims$
          if (ii .le. numdims) then
              if (dims(ii) .ne. dims2(ii)) then
                call mexErrMsgTxt('Incorrect size of input: $pname$')
              end if
          else
            if (dims2(ii) .ne. 1) then
              call mexErrMsgTxt('Incorrect size of input (*): $pname$')
            end if
          end if;
        end do
        DEALLOCATE(dims2)

#### fsetup_output_double

        !$pname$
!CC Scalar output not yet supported

#### fsetup_output_double_array

        !$pname$
        if ($pindex$ .LE. nlhs) then
            ^template check_dimensions_valid
            plhs($pindex$)=mxCreateNumericArray($numdims$,(/ $dimensions$ /),mxClassIDFromClassName('double'),0)
            p_output_$pname$=mxGetPr(plhs($pindex$))
        end if
         ALLOCATE(output_$pname$(int($total_size$)))

#### fsetup_output_double_array_complex

        !$pname$
        if ($pindex$ .LE. nlhs) then
            ^template check_dimensions_valid
            plhs($pindex$)=mxCreateNumericArray($numdims$,(/ $dimensions$ /),mxClassIDFromClassName('double'),1)
            p_output_$pname$_re=mxGetPr(plhs($pindex$))
            p_output_$pname$_im=mxGetPi(plhs($pindex$))
        end if
        ALLOCATE(output_$pname$(int($total_size$)*2))
        ALLOCATE(output_$pname$_re(int($total_size$)))
        ALLOCATE(output_$pname$_im(int($total_size$)))

#### fsetup_output_int_array

        !$pname$
        if ($pindex$ .LE. nlhs) then
            ^template check_dimensions_valid
            plhs($pindex$)=mxCreateNumericArray($numdims$,(/ $dimensions$ /),mxClassIDFromClassName('double'),0)
            p_output_$pname$=mxGetPr(plhs($pindex$))
        end if
        ALLOCATE(output_$pname$(int($total_size$)))
        ALLOCATE(output_$pname$_double(int($total_size$)))

#### check_dimensions_valid

        if (($numdims$ .lt. 1) .or. ($numdims$ .gt. 20)) then
          call mexErrMsgTxt ('Bad number of dimensions for my taste: $numdims$') 
        end if
        ALLOCATE(dims2($numdims$))
        dims2=(/ $dimensions$ /)
        do ii=1,$numdims$
            if ((dims2(ii) .lt. 1) .or. (dims2(ii) .gt. 10000000000.0)) then
              call mexErrMsgTxt ('Bad array size for my taste: $dimensions$') 
            end if
        end do
        DEALLOCATE(dims2)
        
#### fsetup_output_int

!CC Scalar output not yet supported

#### fsetup_set_input_double

        !$pname$
        input_$pname$=$set_value$

#### fsetup_set_input_int

        !$pname$
        input_$pname$=int($set_value$)


#### end

