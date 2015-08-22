
fprintf('\n\n*** Be sure to add the mcwrap directory to your path ***\n\n');
fprintf('\n\n*** You must also install a MATLAB-compatible Fortran compiler ***\n\n');

mcwrap('square_it.mcwrap');

square_it(1:8)