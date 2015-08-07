# mcwrap

Call a C/C++ function from MATLAB without fiddling with MEX.

## Getting started

Just run "test_example1.m"

If you look in the example1 directory you will see two files defining a minimal C++ function. The important thing to realize is that reverse_it.h has some special syntax that MWRAP recognizes. All of the behind-the-scenes files are in the _mcwrap directory, where a mex .cpp file is auto-generated and compiled.

## Pronunciation

MCWRAP is pronounced "emcee rap" or "McWrap", but not "em cwrap".




