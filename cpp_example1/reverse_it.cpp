#include "reverse_it.h"

void reverse_it(int N,float *X_out,float *X_in) {
    for (int i=0; i<N; i++) {
        X_out[N-1-i]=X_in[i];
    }
}