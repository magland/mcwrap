C
C MCWRAP norm_it { y_output[1,$N$] } <- { N , COMPLEX x_input[1,$N$] }
C SOURCES norm_it.F
C void norm_it(int N,double *y_output,double *x_input)
C

C-----------------------------------------------------------------------

        subroutine norm_it(N,y_output, x_input)
        real*8 x_input(N*2), y_output(N*2)

        do ii = 1,N
           y_output(ii) = sqrt(
     +      x_input(ii*2) * x_input(ii*2) +
     +      x_input(ii*2+1) * x_input(ii*2+1)
     +     )
        enddo
        return
        end
