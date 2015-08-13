function json=mcwrap_create_json(code_fname)
% This function is used by mcwrap.m

wrappings={};

ret=true;
str=fileread(code_fname);
lines=strsplit(str,'\n');
wrapping=false;
current_wrapping=struct;
current_sources={};
for j=1:length(lines)
    line=lines{j};
    tokens=tokenize(line);
    tokens=remove_leading_comment_characters(tokens);
    if (length(tokens)>=1)
        token1=tokens{1};
        if (strcmp(token1,'MCWRAP'))
            disp(line);
            % EXAMPLE: MCWRAP reverse_it { X_out[1,$N$] } <- { N , X_in[1,$N$] }
            if (wrapping) error(sprintf('Problem in mcwrap, line %d, already wrapping.',j)); end;
            wrapping=true;
            if (length(tokens)<9) error(sprintf('Problem in mcwrap, not enough tokens, line %d.',j)); end;
            current_wrapping.function_name=tokens{2};
            ind=3;
            [current_wrapping.output_parameters,ind,problem]=parse_parameters(tokens,ind);
            if (ind<=0) error(sprintf('Problem parsing output parameters, line %d: %s',j,problem)); end;
            if (ind+2>length(tokens)) error(sprintf('Problem in mcwrap, not enough tokens (*), line %d.',j)); end;
            if ((~strcmp(tokens{ind},'<'))||(~strcmp(tokens{ind+1},'-'))) error(sprintf('Problem in mcwrap, expected <-, line %d.',j)); end;
            ind=ind+2;
            [current_wrapping.input_parameters,ind,problem]=parse_parameters(tokens,ind);
            if (ind<=0) error(sprintf('Problem parsing input parameters, line %d: %s',j,problem)); end;
        elseif (strcmp(token1,'SOURCES'))
            disp(line);
            if (~wrapping) error(sprintf('Found SOURCE without a MCWRAP, line %d',j)); end;
            for j=2:length(tokens)
                current_sources{end+1}=tokens{j};
            end;
        else
            if (wrapping)
                if (length(tokens)>=2)
                    if (strcmp(tokens{2},current_wrapping.function_name))
                        disp(line);
                        disp(' ');
                        [params,ind,problem]=parse_cpp_parameters(tokens,3);
                        if (ind<=0) error(sprintf('Problem parsing cpp parameters, line %d: %s',j,problem)); end;
                        for j=1:length(params)
                            params{j}.prole='';
                            ind0=find_param(current_wrapping.input_parameters,params{j}.pname);
                            if (ind0>0)
                                params{j}.prole='input';
                                params{j}.dimensions=current_wrapping.input_parameters{ind0}.dimensions;
                                params{j}.is_complex=current_wrapping.input_parameters{ind0}.is_complex;
                            end;
                            ind0=find_param(current_wrapping.output_parameters,params{j}.pname);
                            if (ind0>0)
                                if (strcmp(params{j}.prole,'input')) params{j}.prole='inoutput'
                                else params{j}.prole='output'; end;
                                params{j}.dimensions=current_wrapping.output_parameters{ind0}.dimensions;
                                params{j}.is_complex=current_wrapping.output_parameters{ind0}.is_complex;
                            end;
                            if (isempty(params{j}.prole))
                                error(sprintf('Unable to find parameter in MCWRAP macro, %s, line %d: %s',params{j}.pname,j,problem));
                            end;
                        end;
                        current_wrapping.params=params;
                        current_wrapping.sources=current_sources;
                        current_wrapping=rmfield(current_wrapping,'input_parameters');
                        current_wrapping=rmfield(current_wrapping,'output_parameters');
                        wrappings{end+1}=current_wrapping;
                        current_wrapping=struct;
                        current_sources={};
                        wrapping=false;
                    end;
                end;
            end;
        end;
    end;
end;

fprintf('Processed %d wrappings.\n',length(wrappings));

disp('Creating JSON...');
list={};
list{end+1}=sprintf('[');
for j=1:length(wrappings)
    wrapping=wrappings{j};
    list{end+1}=sprintf('{');
    list{end+1}=sprintf('\t"function_name":"%s",',wrapping.function_name);
    list{end+1}=sprintf('\t"parameters"[');
    for k=1:length(wrapping.params)
        param=wrapping.params{k};
        comma='';
        if (k<length(wrapping.params)) comma=','; end;
        dims_str='';
        for aa=1:length(param.dimensions)
            if (aa>1) dims_str=[dims_str,',']; end;
            dims_str=[dims_str,'"',param.dimensions{aa},'"'];
        end;
        list{end+1}=sprintf('\t\t{"prole":"%s","ptype":"%s","pname":"%s","dimensions":[%s],"is_complex":"%d"}%s',param.prole,param.ptype,param.pname,dims_str,param.is_complex,comma);
    end;
    list{end+1}=sprintf('\t],');
    list{end+1}=sprintf('\t"return_type":"void"');
    sources_str='';
    for k=1:length(wrapping.sources)
        source=wrapping.sources{k};
        if (k>1) sources_str=[sources_str,',']; end;
        sources_str=[sources_str,sprintf('"%s"',source)];
            
    end;
    list{end+1}=sprintf('\t"sources":[%s]',sources_str);
    comma='';
    if (j<length(wrappings)) comma=','; end;
    list{end+1}=sprintf('}%s',comma);
end;
list{end+1}=sprintf(']');

json=cell_array_to_string(list);

end

function tokens2=remove_leading_comment_characters(tokens)

tokens2={};
found=0;
for j=1:length(tokens)
    token=tokens{j};
    if ((found)||((~strcmp(token,'/'))&&(~strcmp(token,'*')&&(~strcmp(token,'c'))&&(~strcmp(token,'C')))))
        tokens2{end+1}=token;
        found=1;
    end;
end;

end

function [parameters,ind2,problem]=parse_parameters(tokens,ind)
%EXAMPLE: { N , X_in[1,$N$] }
parameters={};
problem='';
if (length(tokens)<2) ind2=-1; problem='Not enough tokens (*)'; return; end;

if (~strcmp(tokens{ind},'{')) ind2=-1; problem='Expected {'; return; end;
j=ind+1;
while ((j<=length(tokens))&&(~strcmp(tokens{j},'}')))
    j=j+1;
end;
if (j>length(tokens)) ind2=-1; problem='Not enough tokens'; return; end;
tokens2={};
ind2=j+1;
for j=ind+1:j-1
    tokens2{end+1}=tokens{j};
end;

empty_current_param=struct; empty_current_param.pname=''; empty_current_param.dimensions={}; empty_current_param.is_complex=0;
current_param=empty_current_param;
current_dim='';

in_brackets=false;
ii=1;
while (ii<=length(tokens2))
    token=tokens2{ii};
    if (~in_brackets)
        if (strcmp(token,','))
            if (isempty(current_param.pname)) ind2=-1; problem='found comma, but pname is empty'; end;
            parameters{end+1}=current_param;
            current_param=empty_current_param;
        elseif (strcmp(token,'['))
            if (isempty(current_param.pname)) ind2=-1; problem='found [ but pname is empty'; end;
            in_brackets=true;
        else
            if (~isempty(current_param.pname)) ind2=-1; problem='pname is not empty'; end;
            if (strcmp(token,'COMPLEX')) current_param.is_complex=1;
            else current_param.pname=token; end;
        end;
    else
        if (strcmp(token,','))
            if (isempty(current_dim)) ind2=-1; problem='found comma, but current_dim is empty'; end;
            current_param.dimensions{end+1}=current_dim;
            current_dim='';
        elseif (strcmp(token,']'))
            if (~isempty(current_dim))
                current_param.dimensions{end+1}=current_dim;
                current_dim='';
            end;
            in_brackets=false;
        else
            current_dim=[current_dim,token];
        end;
    end;
    ii=ii+1;
end;
if (~isempty(current_param.pname))
    parameters{end+1}=current_param;
    current_param=empty_current_param;
end;

end

function [parameters,ind2,problem]=parse_cpp_parameters(tokens,ind)
%EXAMPLE: (int N,float *X_out,float *X_in)
parameters={};
problem='';
if (length(tokens)<2) ind2=-1; problem='Not enough tokens (*)'; return; end;

if (~strcmp(tokens{ind},'(')) ind2=-1; problem='Expected ('; return; end;
j=ind+1;
while ((j<=length(tokens))&&(~strcmp(tokens{j},')')))
    j=j+1;
end;
if (j>length(tokens)) ind2=-1; problem='Not enough tokens'; return; end;
tokens2={};
ind2=j+1;
for j=ind+1:j-1
    tokens2{end+1}=tokens{j};
end;

ii=1;
while (ii<=length(tokens2))
    jj=ii+1;
    while ((jj<=length(tokens2))&&(~strcmp(tokens2{jj},','))) jj=jj+1; end;
    list={};
    for kk=ii:jj-1;
        list{end+1}=tokens2{kk};
    end;
    if (length(list)<2) 
        ind2=-1; problem='The length of the list is less than 2'; 
    end;
    ptype0=''; for kk=1:length(list)-1 ptype0=[ptype0,list{kk}]; end;
    parameters{end+1}=struct('pname',list{end},'ptype',ptype0);
    ii=jj+1;
end;

end

function ind=find_param(params,pname)

ind=-1;
for j=1:length(params)
    if (strcmp(params{j}.pname,pname))
        ind=j;
    end;
end;

end

function str=cell_array_to_string(list)
str='';
for j=1:length(list)
    str=[str,list{j},char(10)];
end;
end

function tokens=tokenize(line)

tic;
token_strings='!@#$%^&*()-=+|''"{}[]/,;';
%first split by whitespace
list=strsplit(line);

list2={};
for kk=1:length(list)
    str=list{kk};
    ii=1;
    for a=1:length(str)
        if (strfind(token_strings,str(a)))
            if (ii<a) list2{end+1}=str(ii:a-1); end;
            list2{end+1}=str(a);
            ii=a+1;
        end;
    end;
    if (ii<=length(str))
        list2{end+1}=str(ii:end);
    end;
end;

tokens=list2;

end
