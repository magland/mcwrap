addpath('cpp_example_complex');

% Compile
mcwrap('cpp_example_complex/conjugate_it.h');

% Run
X=[1+i,2+i,4+4i,9-2i,16];
conjugate_it(length(X),X)
