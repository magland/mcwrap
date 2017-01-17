# mcwrap

Call a C/C++ function from MATLAB without fiddling with MEX.

This is a matlab program that automatically generates and compiles MEX code using a minimal syntax provided by the user.

(Note that direct fortran wrapping is no longer supported. Instead, wrap the fortran using C, then apply mcwrap.)

## Getting started

Make sure you have set up a MATLAB-compatible C++ compiler.

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

Other options available in the wrapping syntax:

* MEXARGS -- pass additional (arbitrary) arguments to the mex compiler

Notes and limitations
* Help .m files are automatically generated for each wrapped function.
* Complex arrays ARE supported, but it is assumed that the wrapped function operates on double arrays of size 2*N, with alternating real and imaginary parts.
* For now only the following input/output types are supported: integer, double, double array, complex double array
* Scalar outputs must be treated as arrays of size 1
* The MCWRAP syntax may be included in the comments of the source .h/.f file or may be included in a separate .mcwrap file
* Multiple .cpp/.F source files may be specified
* Multiple functions may be wrapped using a single .mcwrap file

## Common pitfalls (in case something crashes)

* It is very important that your array dimensions are correct. MCWRAP will check the inputs at run time to see if the matlab variable dimensions match your specification. However, it cannot check whether the internal function call is expecting those dimensions. If not, there could be an out-of-bounds memory access segmentation fault.

* Be sure to declare complex variables with the "COMPLEX" keyword! For example, in the above example you could use:
```c++
 * MCWRAP [ COMPLEX X_out[1,N] ] = reverse_it( COMPLEX X_in[1,N] )
```

## Pronunciation

MCWRAP is pronounced "emcee rap"

