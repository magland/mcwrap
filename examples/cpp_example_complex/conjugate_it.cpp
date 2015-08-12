#include "conjugate_it.h"

void conjugate_it(int N,float *X_out,float *X_in) {
    for (int i=0; i<N; i++) {
        X_out[2*i]=X_in[2*i];
        X_out[2*i+1]=-X_in[2*i+1];
    }
}