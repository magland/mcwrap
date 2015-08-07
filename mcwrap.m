function mcwrap(cpp_header_fname)
%MCWRAP - Auto-wrap a C/C++ file to be called from matlab
% Call a C/C++ function with minimal complexity, no mex programming
%
% Syntax:  [] = mcwrap(cpp_header_fname)
%
% Inputs:
%    cpp_header_fname - The path to a .h file, which must have been
%    prepared with special MCWRAP syntax
%
% Outputs:
%    <none>
%
% Example: 
%    See example1 directory
%
% Other m-files required: parse_json.m
% Other files required: all .txt files in the "templates" directory

% Author: Jeremy Magland, Ph.D.
% email address: jeremy.magland@gmail.com
% Website: http://magland.github.io
% August 2015; Last revision: 7-Aug-2015

[dirname,basename]=fileparts(cpp_header_fname);
if (isempty(dirname)) dirname='.'; end;
if (~exist(sprintf('%s/_mcwrap',dirname),'dir'))
    mkdir(sprintf('%s/_mcwrap',dirname));
end;

json=mcwrap_part_1(cpp_header_fname);
json_fname=sprintf('%s/_mcwrap/mcwrap_%s.json',dirname,basename);
FF=fopen(json_fname,'w');
fprintf(FF,'%s',json);
fclose(FF);

[~,h_base_name]=fileparts(cpp_header_fname);
mcwrap_part_2(h_base_name,json_fname);

%tokens=tokenize('/* this is a test */');
%remove_leading_comment_characters(tokens)

end

function json=mcwrap_part_1(cpp_header_fname)

wrappings={};

ret=true;
str=fileread(cpp_header_fname);
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
        elseif (strcmp(token1,'SOURCE'))
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
                            end;
                            ind0=find_param(current_wrapping.output_parameters,params{j}.pname);
                            if (ind0>0)
                                if (strcmp(params{j}.prole,'input')) params{j}.prole='inoutput'
                                else params{j}.prole='output'; end;
                                params{j}.dimensions=current_wrapping.output_parameters{ind0}.dimensions;
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
        list{end+1}=sprintf('\t\t{"prole":"%s","ptype":"%s","pname":"%s","dimensions":[%s]}%s',param.prole,param.ptype,param.pname,dims_str,comma);
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

empty_current_param=struct; empty_current_param.pname=''; empty_current_param.dimensions={};
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
            current_param.pname=token;
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

function tokens=tokenize(line)

token_strings={'*',';','+',',','-','/','(',')','{','}','[',']','&','@','#','^','=','|','''','"'};
list=strsplit(line);
for kk=1:length(token_strings)
    token_string=token_strings{kk};
    list2={};
    for j=1:length(list)
        tmp=list{j};
        tmp2=strsplit(tmp,token_string);
        for ii=1:length(tmp2)
            if (ii>1) list2{end+1}=token_string; end;
            list2{end+1}=tmp2{ii};
        end;
    end;
    list=list2;
end;
tokens={};
for j=1:length(list)
    if (length(list{j})>0) tokens{end+1}=list{j}; end;
end;

end

function tokens2=remove_leading_comment_characters(tokens)

tokens2={};
found=0;
for j=1:length(tokens)
    token=tokens{j};
    if ((found)||((~strcmp(token,'/'))&&(~strcmp(token,'*'))))
        tokens2{end+1}=token;
        found=1;
    end;
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

function mcwrap_part_2(h_base_name,json_fname)

mcwrap_dirname=fileparts(json_fname);

JSON=parse_json(fileread([mcwrap_dirname,'/mcwrap_reverse_it.json']));

for j=1:length(JSON)

    XX=JSON{j}{1};
    function_name=XX.function_name;

    input_parameters={};
    output_parameters={};
    arguments='';
    for j=1:length(XX.parameters)
        if (strcmp(XX.parameters{j}.prole,'input'))
            input_parameters{end+1}=XX.parameters{j};
        elseif (strcmp(XX.parameters{j}.prole,'output'))
            output_parameters{end+1}=XX.parameters{j};
        end;
        if (j>1) arguments=[arguments,',']; end;
        arguments=[arguments,'$',XX.parameters{j}.pname,'$'];
    end;

    m_file_path=fileparts(mfilename('fullpath'));
    template_dir=[m_file_path,'/templates'];
    
    code=fileread([template_dir,'/template1.txt']);

    code=strrep(code,'$h_base_name$',h_base_name);
    code=strrep(code,'$function_name$',function_name);
    code=strrep(code,'$arguments$',arguments);
    code=strrep(code,'$nrhs$',sprintf('%d',length(input_parameters)));
    code=strrep(code,'$nlhs$',sprintf('%d',length(output_parameters)));

    set_up_inputs='';
    for j=1:length(input_parameters)
        PP=input_parameters{j};
        tmp='';
        if ((strcmp(PP.ptype,'float*'))||(strcmp(PP.ptype,'double*')))
            tmp=fileread([template_dir,'/template_set_up_inputs_real_array.txt']);
            tmp=strrep(tmp,'$pname$',PP.pname);
            total_size='';
            for k=1:length(PP.dimensions)
                if (k>1) total_size=[total_size,'*']; end;
                total_size=sprintf('%s(%s)',total_size,PP.dimensions{k});
            end;
            tmp=strrep(tmp,'$total_size$',total_size);
            if (strcmp(PP.ptype,'float*'))
                tmp=strrep(tmp,'$dtype$','float');
            elseif (strcmp(PP.ptype,'double*'))
                tmp=strrep(tmp,'$dtype$','double');
            end;
        elseif ((strcmp(PP.ptype,'int'))||(strcmp(PP.ptype,'float'))||(strcmp(PP.ptype,'double')))
            tmp=fileread([template_dir,'/template_set_up_inputs_scalar.txt']);
            tmp=strrep(tmp,'$pname$',PP.pname);
            tmp=strrep(tmp,'$dtype$',PP.ptype);
        end;
        tmp=strrep(tmp,'$rhs_index$',sprintf('%d',j-1));
        set_up_inputs=[set_up_inputs,char(9),'/// ',PP.pname,' (',PP.ptype,')',char(10),tmp,char(10)];
    end;
    code=strrep(code,'$set_up_inputs$',set_up_inputs);

    set_up_outputs='';
    for j=1:length(output_parameters)
        PP=output_parameters{j};
        tmp='';
        if ((strcmp(PP.ptype,'float*'))||(strcmp(PP.ptype,'double*')))
            tmp=fileread([template_dir,'/template_set_up_outputs_real_array.txt']);
            tmp=strrep(tmp,'$pname$',PP.pname);
            total_size='';
            for k=1:length(PP.dimensions)
                if (k>1) total_size=[total_size,'*']; end;
                total_size=sprintf('%s(%s)',total_size,PP.dimensions{k});
            end;
            tmp=strrep(tmp,'$total_size$',total_size);
            if (strcmp(PP.ptype,'float*'))
                tmp=strrep(tmp,'$dtype$','float');
            elseif (strcmp(PP.ptype,'double*'))
                tmp=strrep(tmp,'$dtype$','double');
            end;
            dims_str='';
            for kk=1:length(PP.dimensions)
                if (kk>1) dims_str=[dims_str,',']; end;
                dims_str=[dims_str,PP.dimensions{kk}];
            end;
            tmp=strrep(tmp,'$dims$',dims_str);
        elseif ((strcmp(PP.ptype,'int'))||(strcmp(PP.ptype,'float'))||(strcmp(PP.ptype,'double')))
            tmp=fileread([template_dir,'/template_set_up_outputs_scalar.txt']);
            tmp=strrep(tmp,'$pname$',PP.pname);
            tmp=strrep(tmp,'$dtype$',PP.ptype);
        end;
        tmp=strrep(tmp,'$lhs_index$',sprintf('%d',j-1));
        set_up_outputs=[set_up_outputs,char(9),'/// ',PP.pname,' (',PP.ptype,')',char(10),tmp,char(10)];
    end;
    code=strrep(code,'$set_up_outputs$',set_up_outputs);

    free_inputs='';
    for pp=1:length(input_parameters)
        PP=input_parameters{pp};
        if ((strcmp(PP.ptype,'float*'))||(strcmp(PP.ptype,'double*')))
            free_inputs=[free_inputs,sprintf('\tfree($%s$);\n',PP.pname)];
        end;
    end;
    code=strrep(code,'$free_inputs$',free_inputs);

    set_outputs='';
    for pp=1:length(output_parameters)
        PP=output_parameters{pp};
        if ((strcmp(PP.ptype,'float*'))||(strcmp(PP.ptype,'double*')))
            tmp=fileread([template_dir,'/template_set_outputs_real_array.txt']);
            tmp=strrep(tmp,'$pname$',PP.pname);
            total_size='';
            for k=1:length(PP.dimensions)
                if (k>1) total_size=[total_size,'*']; end;
                total_size=sprintf('%s(%s)',total_size,PP.dimensions{k});
            end;
            tmp=strrep(tmp,'$total_size$',total_size);
        elseif ((strcmp(PP.ptype,'int'))||(strcmp(PP.ptype,'float'))||(strcmp(PP.ptype,'double')))
            tmp=fileread([template_dir,'/template_set_outputs_scalar.txt']);
        end
        set_outputs=[set_outputs,char(9),'/// ',PP.pname,' (',PP.ptype,')',char(10),tmp,char(10)];
    end;
    code=strrep(code,'$set_outputs$',set_outputs);

    for pp=1:length(input_parameters)
        code=strrep(code,['$',input_parameters{pp}.pname,'$'],['input_',input_parameters{pp}.pname]);
    end;
    for pp=1:length(output_parameters)
        code=strrep(code,['$',output_parameters{pp}.pname,'$'],['output_',output_parameters{pp}.pname]);
    end;

    mex_cpp_fname=sprintf('%s/mcwrap_%s.cpp',mcwrap_dirname,function_name);
    F=fopen(mex_cpp_fname,'w');
    fprintf(F,'%s',code);
    fclose(F);
    
    evalstr=['mex ',mex_cpp_fname];
    for aa=1:length(XX.sources)
        evalstr=[evalstr,' ',sprintf('%s/../%s',mcwrap_dirname,XX.sources{aa})];
    end
    evalstr=[evalstr,' -output ',mcwrap_dirname,'/../',function_name];
    disp(evalstr);
    eval(evalstr);
end;

end
