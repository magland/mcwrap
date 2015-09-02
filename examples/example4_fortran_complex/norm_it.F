
        subroutine norm_it(N,y_output, x_input)
        real*8 x_input(N*2), y_output(N*2)

        do ii = 1,N
           y_output(ii) = sqrt(
     +      x_input(1+(ii-1)*2) ** 2 +
     +      x_input(1+(ii-1)*2+1) ** 2
     +     )
        enddo

        return
        end
