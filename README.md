# mcwrap

Call a C/C++ function from MATLAB without fiddling with MEX.

## Getting started

Just run "run_cpp_example1.m" or "run_fortran_example1.m"

If you look in the example directories you will see the source .h/.cpp/.F files. The important thing to realize is that reverse_it.h and square_it.F have some special syntax that MWRAP recognizes. All of the behind-the-scenes files are in the _mcwrap directory, where a mex .cpp or .F file is auto-generated and compiled.

## Pronunciation

MCWRAP is pronounced "emcee rap" or "McWrap", but not "em cwrap".
