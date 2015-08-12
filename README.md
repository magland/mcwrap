# mcwrap

Call a C/C++ function from MATLAB without fiddling with MEX.

## Getting started

Just cd into the mcwrap directory and run "run_examples.m"

If you look in the example directories you will see the source .h/.cpp/.F files. The important thing to realize is that reverse_it.h and square_it.F have some special syntax that MCWRAP recognizes. All of the behind-the-scenes files are in the _mcwrap directory, where a mex .cpp or .F file is auto-generated and compiled.

## Pronunciation

MCWRAP is pronounced "emcee rap"