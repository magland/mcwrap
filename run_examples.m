disp('cpp_example1');
mcwrap('examples/cpp_example1/reverse_it.h');
addpath([pwd,'/examples/cpp_example1']);
X=[1,2,4,9,16];
reverse_it(length(X),X)

disp('fortran_example1');
mcwrap('examples/fortran_example1/square_it.F');
addpath([pwd,'/examples/fortran_example1']);
X=[1,2,4,9,16];
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
