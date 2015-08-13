C
C MCWRAP square_it { y_output[1,$N$] } <- { N , x_input[1,$N$] }
C SOURCES square_it.F
C void square_it(int N,double *y_output,double *x_input)
C

C-----------------------------------------------------------------------

        subroutine square_it(N,y_output, x_input)
        real*8 x_input(N), y_output(N)

        do ii = 1,N
           y_output(ii) = x_input(ii) * x_input(ii)
        enddo
        return
        end
