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
