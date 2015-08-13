#ifndef conjugate_it_h
#define conjugate_it_h

/*
 * MCWRAP conjugate_it { COMPLEX X_out[1,$N$] } <- { N , COMPLEX X_in[1,$N$] }
 * SOURCES conjugate_it.cpp
 */

//return the complex conjugate of a vector
void conjugate_it(int N,float *X_out,float *X_in);

#endif
