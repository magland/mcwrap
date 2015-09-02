addpath('fortran_example1');

% Compile
mcwrap('fortran_example1/square_it.F');

% Run
X=[1,2,4,9,16,25];
X=reshape(X,size(X,1),size(X,2)/2,2);
size(X)
square_it(length(X),X)
