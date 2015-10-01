# mcwrap

Call a C/C++/Fortran function from MATLAB without fiddling with MEX.

This is a matlab program that automatically generates and compiles MEX code using a minimal syntax provided by the user.

## Getting started

Make sure you have set up a MATLAB-compatible C++ compiler (or Fortran compiler if needed).

Just cd into the example directories and run the test programs

Here is a minimal example for C++ (source file not shown)

```c++
#ifndef reverse_it_h
#define reverse_it_h

/*
 * MCWRAP [ X_out[1,N] ] = reverse_it( X_in[1,N] )
 *   SET_INPUT N = size(X_in,2)
 *   SOURCES reverse_it.cpp
 *   HEADERS reverse_it.h
 */

//reverse the order of a vector
void reverse_it(int N,double *X_out,double *X_in);

#endif
```

The MCWRAP syntax in the comments tells mcwrap how to do the wrapping.

From the MATLAB console you only need to run:
```MATLAB
mcwrap('reverse_it.h')
```
Then you may call reverse_it directly from MATLAB.

A minimal example for FORTRAN is shown here:

```fortran
C    MCWRAP [ y_output[1, N] ] = square_it( x_input[1, N] )
C      SET_INPUT N = size(x_input,2)
C      SOURCES square_it.F
C      void square_it(int N,double *y_output,double *x_input)
    
        subroutine square_it(N,y_output,x_input)
        real*8 x_input(N), y_output(N)

        do ii = 1,N
           y_output(ii) = x_input(ii) ** 2
        enddo

        return
        end
```

Again just call from MATLAB:
```MATLAB
mcwrap('square_it.F')
```
and then you may call square_it directly.

Notes and limitations
* Help .m files are automatically generated for each wrapped function.
* Complex arrays ARE supported, but it is assumed that the wrapped function operates on double arrays of size 2*N, with alternating real and imaginary parts.
* For now only the following input/output types are supported: integer, double, double array, complex double array
* Scalar outputs must be treated as arrays of size 1
* The MCWRAP syntax may be included in the comments of the source .h/.f file or may be included in a separate .mcwrap file
* Multiple .cpp/.F source files may be specified
* Multiple functions may be wrapped using a single .mcwrap file

## Common pitfalls (in case something crashes)

* Be sure to declare complex variables with the "COMPLEX" keyword! For example, in the above example you could use:
```fortran
C    MCWRAP [ COMPLEX y_output[1, N] ] = square_it( COMPLEX x_input[1, N] )
```

## Pronunciation

MCWRAP is pronounced "emcee rap"

