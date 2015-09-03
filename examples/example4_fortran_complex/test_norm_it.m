
fprintf('\n\n*** Be sure to add the mcwrap directory to your path ***\n\n');
fprintf('\n\n*** You must also install a MATLAB-compatible Fortran compiler ***\n\n');

mcwrap('norm_it.mcwrap');

norm_it([1,1+i,1-i,5i,-3i,3+4i])