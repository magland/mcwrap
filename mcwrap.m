function mcwrap(code_fname)
%MCWRAP - Auto-wrap a C/C++ file to be called from matlab
% Call a C/C++ function with minimal complexity, no mex programming
%
% Syntax:  [] = mcwrap(code_fname)
%
% Inputs:
%    code_fname - The path to a .h or .mcwrap file, which must have been
%    prepared with special MCWRAP syntax
%
% Outputs:
%    <none>
%
% Example: 
%    See example1 directory
%
% Other m-files required: parse_json.m, mcwrap_create_json.m
% Other files required: all .txt files in the "templates" directory

% Author: Jeremy Magland, Ph.D.
% email address: jeremy.magland@gmail.com
% Website: http://magland.github.io
% August 2015; Last revision: 22-Aug-2015

% to do:
%   document the prerequisites: include install gfortran


[dirname,code_basename,extension]=fileparts(code_fname);
if (isempty(dirname)) dirname='.'; end;


json=mcwrap_create_json(code_fname);
json_fname=sprintf('%s/_mcwrap/mcwrap_%s.json',dirname,code_basename);

if (~exist(sprintf('%s/_mcwrap',dirname),'dir'))
    mkdir(sprintf('%s/_mcwrap',dirname));
end;

FF=fopen(json_fname,'w');
fprintf(FF,'%s',json);
fclose(FF);

JSON=parse_json(fileread(json_fname));
m_file_path=fileparts(mfilename('fullpath'));
template_dir=[m_file_path,'/templates'];
compile_mex_code='';

JSON=JSON{1};
for j=1:length(JSON)
    XX=JSON{j};
    
    is_fortran=0;
    for j=1:length(XX.sources)
        source0=lower(XX.sources{1});
        if ((strcmp(source0(end-1:end),'.f'))||(strcmp(source0(end-3:end),'.f90'))||(strcmp(source0(end-3:end),'.f77')))
            is_fortran=1;
        end;
    end;
    
    is_fortran=0;
    for j=1:length(XX.sources)
        source0=XX.sources{1};
        if ((strcmp(source0(end-1:end),'.f'))||(strcmp(source0(end-1:end),'.F'))||(strcmp(source0(end-3:end),'.f77'))||(strcmp(source0(end-3:end),'.f90')))
            is_fortran=1;
        end;
    end;
    
    input_parameters={};
    output_parameters={};
    set_input_parameters={};
    headers=XX.headers;
    arguments='';
    for j=1:length(XX.parameters)
        arguments=[arguments,'        '];
        if (strcmp(XX.parameters{j}.prole,'input'))
            input_parameters{end+1}=XX.parameters{j};
            arguments=[arguments,'input_',XX.parameters{j}.pname];
        elseif (strcmp(XX.parameters{j}.prole,'output'))
            output_parameters{end+1}=XX.parameters{j};
            arguments=[arguments,'output_',XX.parameters{j}.pname];
        elseif (strcmp(XX.parameters{j}.prole,'set_input'))
            set_input_parameters{end+1}=XX.parameters{j};
            arguments=[arguments,'input_',XX.parameters{j}.pname];
        end;
        if (j<length(XX.parameters)) arguments=[arguments,',']; end;
        arguments=[arguments,sprintf(' &\n')];
    end;
    if (~is_fortran)
        arguments=strrep(arguments,' &','');
    end;
    
    if (~is_fortran)
<<<<<<< HEAD
        template_txt=fileread([template_dir,'/cpptemplate.txt']);
    elseif (is_fortran)
        template_txt=fileread([template_dir,'/ftemplate.txt']);
=======
        template_txt=fileread([template_dir,'/cpp_template.cpp']);
    elseif (is_fortran)
        template_txt=fileread([template_dir,'/fortran_template.f']);
>>>>>>> cb589906876c44407cbbb77680e8c74223ac548d
    end;
    template_code=get_template_code(template_txt,'main');
    disp(sprintf('evaluating template for %s...',XX.function_name));
    code_lines=evaluate_template(template_txt,template_code,input_parameters,output_parameters,set_input_parameters,[],headers);
    code=cell_array_to_string(code_lines);
    
    code=strrep(code,'$num_inputs$',sprintf('%d',length(input_parameters)));
    code=strrep(code,'$num_outputs$',sprintf('%d',length(output_parameters)));
    code=strrep(code,'$num_set_inputs$',sprintf('%d',length(set_input_parameters)));
    code=strrep(code,'$function_name$',XX.function_name);
    code=strrep(code,'$arguments$',arguments);
    code=strrep(code,'$code_basename$',code_basename);
    
    for kk=1:length(input_parameters)
        code=strrep(code,sprintf('$%s$',input_parameters{kk}.pname),sprintf('input_%s',input_parameters{kk}.pname));
<<<<<<< HEAD
    end;
    
    if (~is_fortran)
        mex_source_fname=sprintf('%s/_mcwrap/mcwrap_%s.cpp',dirname,XX.function_name);
    elseif (is_fortran) %% is this a problem -- changed from mysterious other
        mex_source_fname=sprintf('%s/_mcwrap/mcwrap_%s.F',dirname,XX.function_name);
=======
        if (~is_fortran)
            code=strrep(code,sprintf('<%s>',input_parameters{kk}.pname),sprintf('prhs[%d-1]',kk));
        else
            code=strrep(code,sprintf('<%s>',input_parameters{kk}.pname),sprintf('prhs(%d)',kk));
        end;
    end;
    for kk=1:length(set_input_parameters)
        code=strrep(code,sprintf('$%s$',set_input_parameters{kk}.pname),sprintf('input_%s',set_input_parameters{kk}.pname));
    end;
    
%     if (strcmp(extension,'.h'))
%         mex_source_fname=sprintf('%s/_mcwrap/mcwrap_%s.cpp',dirname,XX.function_name);
%     elseif (strcmp(XX.parameters{j}.prole,'output'))
%         mex_source_fname=sprintf('%s/_mcwrap/mcwrap_%s.F90',dirname,XX.function_name);
%     end;

    if (~is_fortran)
        mex_source_fname=sprintf('%s/_mcwrap/mcwrap_%s.cpp',dirname,XX.function_name);
    elseif (is_fortran)
        mex_source_fname=sprintf('%s/_mcwrap/mcwrap_%s.F90',dirname,XX.function_name);
>>>>>>> cb589906876c44407cbbb77680e8c74223ac548d
    end;
    
    FF=fopen(mex_source_fname,'w');
    fprintf(FF,'%s',code);
    fclose(FF);
    
    evalstr=['mex ',mex_source_fname]; %capital .F is needed to run preprocessor correctly
    for aa=1:length(XX.sources)
        evalstr=[evalstr,' ',sprintf('%s/%s',dirname,XX.sources{aa})];
    end
    evalstr=[evalstr,' -output ',dirname,'/',XX.function_name];
    disp(evalstr);
    compile_mex_code=[compile_mex_code,sprintf('%s\n',evalstr)];
    eval(evalstr);
    
    % m file for help
    template_txt=fileread([template_dir,'/mfile_template.m']);
    template_code=get_template_code(template_txt,'main');
    code_lines=evaluate_template(template_txt,template_code,input_parameters,output_parameters,set_input_parameters,[],headers);
    code=cell_array_to_string(code_lines);
    multi_line_description='';
    input_parameter_list='';
    for jj=1:length(input_parameters)
        if (jj>1) input_parameter_list=[input_parameter_list,', ']; end;
        input_parameter_list=[input_parameter_list,input_parameters{jj}.pname];
    end;
    output_parameter_list='';
    for jj=1:length(output_parameters)
        if (jj>1) output_parameter_list=[output_parameter_list,', ']; end;
        output_parameter_list=[output_parameter_list,output_parameters{jj}.pname];
    end;
    code=strrep(code,'$function_name$',XX.function_name);
    code=strrep(code,'$function_name_caps$',upper(XX.function_name));
    code=strrep(code,'$input_parameter_list$',input_parameter_list);
    code=strrep(code,'$output_parameter_list$',output_parameter_list);
    code=strrep(code,'$one_line_description$','');
    code=strrep(code,'$multi_line_description$',multi_line_description);
    if (~isempty(multi_line_description))
        code=strrep(code,'$has_multi_line_description$','1');
    else
        code=strrep(code,'$has_multi_line_description$','0');
    end;
    code=strrep(code,'$','');
    code=strrep(code,' ()','');
    
    
    mfile_fname=sprintf('%s/%s.m',dirname,XX.function_name);
    FF=fopen(mfile_fname,'w');
    fprintf(FF,'%s',code);
    fclose(FF);
    
end;

compile_mex_fname=sprintf('%s/compile_mex_%s.m',dirname,code_basename);
fprintf('Writing %s...',compile_mex_fname);
FF=fopen(compile_mex_fname,'w');
fprintf(FF,'%s',compile_mex_code);
fclose(FF);
    
disp('done.');

end

function code_lines=evaluate_template(template_txt,code,input_parameters,output_parameters,set_input_parameters,current_parameter,headers)

code_lines={};
lines=strsplit(code,'\n','CollapseDelimiters',false);
jj=1;
while (jj<=length(lines))
    tokens=tokenize(lines{jj});
    if ((length(tokens)>=2)&&(strcmp(tokens{1},'@')))
        kk=jj+1;
        depth=1; found=0;
        while ((kk<=length(lines))&&(~found))
            tokens2=tokenize(lines{kk});
            if ((length(tokens2)>=2))
                if (strcmp(tokens2{1},'@'))
                    if (strcmp(tokens2{2},'end'))
                        depth=depth-1;
                        if (depth==0)
                            found=1;
                        end;
                    else
                        depth=depth+1;
                    end;
                end;
            end;
            if (~found) kk=kk+1; end;
        end;
        txt2='';
        for ii=jj+1:kk-1
            if (ii>jj+1) txt2=[txt2,char(10)]; end;
            txt2=[txt2,lines{ii}];
        end;
        if ((strcmp(tokens{2},'foreach'))&&(length(tokens)>=3)&&(strcmp(tokens{3},'header')))
            for ii=1:length(headers)
                txt3=txt2;
                txt3=strrep(txt3,'$header$',headers{ii});
                LLL=strsplit(txt3,'\n');
                for aa=1:length(LLL)
                    code_lines{end+1}=LLL{aa};
                end;
            end;
        elseif ((strcmp(tokens{2},'foreach'))&&(length(tokens)>=3))
            parameters={};
            if (strcmp(tokens{3},'input'))
                parameters=input_parameters;
            elseif (strcmp(tokens{3},'output'))
                parameters=output_parameters;
            elseif (strcmp(tokens{3},'set_input'))
                parameters=set_input_parameters;
            end;
            for ii=1:length(parameters)
                PP=parameters{ii};
                PP.pindex=ii;
                PP.dtype=strrep(PP.ptype,'*','');
                PP.is_array=(length(strfind(PP.ptype,'*'))>0);
                txt3=txt2;
                txt3=strrep(txt3,'$ptype$',PP.ptype);
                txt3=strrep(txt3,'$dtype$',PP.dtype);
                txt3=strrep(txt3,'$is_array$',sprintf('%d',PP.is_array));
                txt3=strrep(txt3,'$is_complex$',sprintf('%d',PP.is_complex));
                txt3=strrep(txt3,'$set_value$',sprintf('%s',PP.set_value));
                if (strcmp(PP.is_complex,'1'))
                    txt3=strrep(txt3,'$underscore_complex$','_complex');
                    txt3=strrep(txt3,'$complex_space$','complex ');
                else
                    txt3=strrep(txt3,'$underscore_complex$','');
                    txt3=strrep(txt3,'$complex_space$','');
                end;
                code_lines2=evaluate_template(template_txt,txt3,input_parameters,output_parameters,set_input_parameters,PP,headers);
                for aa=1:length(code_lines2)
                    code_lines{end+1}=code_lines2{aa};
                end;
            end;
        elseif ((strcmp(tokens{2},'if'))&&(length(tokens)>=5))
            if (evaluate_if(tokens))
                code_lines2=evaluate_template(template_txt,txt2,input_parameters,output_parameters,set_input_parameters,current_parameter,headers);
                for aa=1:length(code_lines2)
                    code_lines{end+1}=code_lines2{aa};
                end;
            end;
        end;
        jj=kk+1;
    elseif ((length(tokens)>=3)&&(strcmp(tokens{1},'^'))&&(strcmp(tokens{2},'template')))
        name0=tokens{3};
        txt2=get_template_code(template_txt,name0);
        code_lines2=evaluate_template(template_txt,txt2,input_parameters,output_parameters,set_input_parameters,current_parameter,headers);
        for aa=1:length(code_lines2)
            code_lines{end+1}=code_lines2{aa};
        end;
        jj=jj+1;
    else
        code_lines{end+1}=lines{jj};
        jj=jj+1;
    end;
end;

if (~isempty(current_parameter))
    PP=current_parameter;
    for aa=1:length(code_lines)
        
        total_size='';
        dimensions='';
        for k=1:length(PP.dimensions)
            if (k>1) total_size=[total_size,'*']; dimensions=[dimensions,',']; end;
            total_size=sprintf('%s(%s)',total_size,PP.dimensions{k});
            dimensions=[dimensions,PP.dimensions{k}];
        end;
        
        code_lines{aa}=strrep(code_lines{aa},'$ptype$',PP.ptype);
        code_lines{aa}=strrep(code_lines{aa},'$dtype$',PP.dtype);
        code_lines{aa}=strrep(code_lines{aa},'$is_array$',sprintf('%d',PP.is_array));
        code_lines{aa}=strrep(code_lines{aa},'$is_complex$',sprintf('%d',PP.is_complex));
        code_lines{aa}=strrep(code_lines{aa},'$set_value$',sprintf('%s',PP.set_value));
        if (strcmp(PP.is_complex,'1'))
            code_lines{aa}=strrep(code_lines{aa},'$underscore_complex$','_complex');
        else
            code_lines{aa}=strrep(code_lines{aa},'$underscore_complex$','');
        end;
        code_lines{aa}=strrep(code_lines{aa},'$pname$',PP.pname);
        code_lines{aa}=strrep(code_lines{aa},'$dimensions$',dimensions);
        code_lines{aa}=strrep(code_lines{aa},'$numdims$',sprintf('%d',length(PP.dimensions)));
        code_lines{aa}=strrep(code_lines{aa},'$pindex$',sprintf('%d',PP.pindex));
        code_lines{aa}=strrep(code_lines{aa},'$total_size$',total_size);
    end;
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

function str=cell_array_to_string(list)
str='';
for j=1:length(list)
    str=[str,list{j},sprintf('\n')];
end;
end

function ret=evaluate_if(tokens)

ind=0;
for i=1:length(tokens)
    if (strcmp(tokens{i},'='))
        ind=i;
    end;
end;
if (ind==0) ret=0; return; end;
if (ind<=3) ret=0; return; end;
if (ind==4)
    if (length(tokens)~=5) ret=0; return; end;
    ret=strcmp(tokens{3},tokens{5});
    return;
elseif (ind==5)
    if (length(tokens)~=7) ret=0; return; end;
    ret=((strcmp(tokens{3},tokens{6}))&&(strcmp(tokens{4},tokens{7})));
    return;
end;
ret=0;

end

function code=get_template_code(template_txt,name)

ind1=strfind(template_txt,sprintf('#### %s\n',name));
if (length(ind1)==0) 
    code=''; 
    error(['Unable to find template code for ',name]);
    return; 
end;
ind1=ind1(1);
AA=template_txt(ind1:end);
ind2=strfind(AA,char(10));
if (length(ind2)==0) code=''; return; end;
ind2=ind2(1);
AA=AA(ind2+1:end);
ind3=strfind(AA,'#### ');
if (length(ind3)==0) code=''; return; end;
ind3=ind3(1);
AA=AA(1:ind3-1);
ii=1;
while ((ii<=length(AA))&&(AA(ii)==char(10))) ii=ii+1; end;
AA=AA(ii:end);
ii=length(AA);
while ((ii>=1)&&(AA(ii)==char(10))) ii=ii-1; end;
AA=AA(1:ii);

code=AA;

end
