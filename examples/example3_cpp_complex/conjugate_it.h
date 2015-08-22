#ifndef conjugate_it_h
#define conjugate_it_h

/*
 * MCWRAP [ COMPLEX X_out[1,N] ] = conjugate_it( COMPLEX X_in[1,N] )
 *   SET_INPUT N = size(X_in,2)
 *   SOURCES conjugate_it.cpp
 */

//return the complex conjugate of a vector
void conjugate_it(int N,double *X_out,double *X_in);

#endif
