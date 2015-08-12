addpath('fortran_example1');

% Compile
mcwrap('fortran_example1/square_it.F');

% Run
X=[1,2,4,9,16];
square_it(length(X),X)
