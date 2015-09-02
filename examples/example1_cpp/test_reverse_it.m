
fprintf('\n\n*** Be sure to add the mcwrap directory to your path ***\n\n');
fprintf('\n\n*** You must also install a MATLAB-compatible C++ compiler ***\n\n');

mcwrap('reverse_it.h');

reverse_it(1:8)