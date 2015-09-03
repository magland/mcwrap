
        subroutine square_it(N,y_output,x_input)
        real*8 x_input(N), y_output(N)

        do ii = 1,N
           y_output(ii) = x_input(ii) ** 2
        enddo

        return
        end
