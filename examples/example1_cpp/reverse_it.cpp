#include "reverse_it.h"

void reverse_it(int N,double *X_out,double *X_in) {
    for (int i=0; i<N; i++) {
        X_out[N-1-i]=X_in[i];
    }
}