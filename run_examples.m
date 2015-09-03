fprintf('\n\n *** cd to each example directory and run the test program ***\n\n');

<<<<<<< HEAD
disp('fortran_example1');
mcwrap('examples/fortran_example1/square_it.F');
addpath([pwd,'/examples/fortran_example1']);
X=[1,2,4,9,16,25];
square_it(length(X),X)

disp('cpp_example_complex');
mcwrap('examples/cpp_example_complex/conjugate_it.h');
addpath([pwd,'/examples/cpp_example_complex']);
X=[1,2+i,4+4i,9-2i,16];
conjugate_it(length(X),X)

disp('fortran_example_complex');
mcwrap('examples/fortran_example_complex/norm_it.F');
addpath([pwd,'/examples/fortran_example_complex']);
X=[1,2+i,4+4i,9-2i,16];
norm_it(length(X),X)
=======
>>>>>>> e16e252f6eebce03920b17dfd2cd0e3e271cdd77
