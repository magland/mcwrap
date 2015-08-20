function mcwrap(code_fname)
%MCWRAP - Auto-wrap a C/C++ file to be called from matlab
% Call a C/C++ function with minimal complexity, no mex programming
%
% Syntax:  [] = mcwrap(code_fname)
%
% Inputs:
%    code_fname - The path to a .h or .F file, which must have been
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
% August 2015; Last revision: 12-Aug-2015


[dirname,code_basename,extension]=fileparts(code_fname);
if (isempty(dirname)) dirname='.'; end;
if (~exist(sprintf('%s/_mcwrap',dirname),'dir'))
    mkdir(sprintf('%s/_mcwrap',dirname));
end;

json=mcwrap_create_json(code_fname);
json_fname=sprintf('%s/_mcwrap/mcwrap_%s.json',dirname,code_basename);
FF=fopen(json_fname,'w');
fprintf(FF,'%s',json);
fclose(FF);

JSON=parse_json(fileread(json_fname));
m_file_path=fileparts(mfilename('fullpath'));
template_dir=[m_file_path,'/templates'];

for j=1:length(JSON)
    XX=JSON{j}{1};
    
    is_fortran=0;
    for j=1:length(XX.sources)
        source0=lower(XX.sources{1});
        if ((strcmp(source0(end-1:end),'.f'))||(strcmp(source0(end-3:end),'.f90'))||(strcmp(source0(end-3:end),'.f77')))
            is_fortran=1;
        end;
    end;
    
    input_parameters={};
    output_parameters={};
    arguments='';
    for j=1:length(XX.parameters)
        if (j>1) arguments=[arguments,',']; end;
        if (strcmp(XX.parameters{j}.prole,'input'))
            input_parameters{end+1}=XX.parameters{j};
            arguments=[arguments,'input_',XX.parameters{j}.pname];
        elseif (strcmp(XX.parameters{j}.prole,'output'))
            output_parameters{end+1}=XX.parameters{j};
            arguments=[arguments,'output_',XX.parameters{j}.pname];
        end;
    end;
    
    if (~is_fortran)
        template_txt=fileread([template_dir,'/cpptemplate.txt']);
    elseif (is_fortran)
        template_txt=fileread([template_dir,'/ftemplate.txt']);
    end;
    template_code=get_template_code(template_txt,'main');
    disp(sprintf('evaluating template for %s...',XX.function_name));
    code_lines=evaluate_template(template_txt,template_code,input_parameters,output_parameters,[]);
    code=cell_array_to_string(code_lines);
    
    code=strrep(code,'$num_inputs$',sprintf('%d',length(input_parameters)));
    code=strrep(code,'$num_outputs$',sprintf('%d',length(output_parameters)));
    code=strrep(code,'$function_name$',XX.function_name);
    code=strrep(code,'$arguments$',arguments);
    code=strrep(code,'$code_basename$',code_basename);
    
    for kk=1:length(input_parameters)
        code=strrep(code,sprintf('$%s$',input_parameters{kk}.pname),sprintf('input_%s',input_parameters{kk}.pname));
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
    eval(evalstr);
end;
disp('done.');

end

function code_lines=evaluate_template(template_txt,code,input_parameters,output_parameters,current_parameter)

code_lines={};
lines=strsplit(code,'\n','CollapseDelimiters',false);
jj=1;
while (jj<=length(lines))
    tokens=tokenize(lines{jj});
    if ((length(tokens)>=2)&&(strcmp(tokens{1},'%')))
        kk=jj+1;
        depth=1; found=0;
        while ((kk<=length(lines))&&(~found))
            tokens2=tokenize(lines{kk});
            if ((length(tokens2)>=2))
                if (strcmp(tokens2{1},'%'))
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
        if ((strcmp(tokens{2},'foreach'))&&(length(tokens)>=3))
            parameters={};
            if (strcmp(tokens{3},'input'))
                parameters=input_parameters;
            elseif (strcmp(tokens{3},'output'))
                parameters=output_parameters;
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
                if (strcmp(PP.is_complex,'1'))
                    txt3=strrep(txt3,'$underscore_complex$','_complex');
                else
                    txt3=strrep(txt3,'$underscore_complex$','');
                end;
                code_lines2=evaluate_template(template_txt,txt3,input_parameters,output_parameters,PP);
                for aa=1:length(code_lines2)
                    code_lines{end+1}=code_lines2{aa};
                end;
            end;
        elseif ((strcmp(tokens{2},'if'))&&(length(tokens)>=5))
            if (evaluate_if(tokens))
                code_lines2=evaluate_template(template_txt,txt2,input_parameters,output_parameters,current_parameter);
                for aa=1:length(code_lines2)
                    code_lines{end+1}=code_lines2{aa};
                end;
            end;
        end;
        jj=kk+1;
    elseif ((length(tokens)>=3)&&(strcmp(tokens{1},'^'))&&(strcmp(tokens{2},'template')))
        name0=tokens{3};
        txt2=get_template_code(template_txt,name0);
        code_lines2=evaluate_template(template_txt,txt2,input_parameters,output_parameters,current_parameter);
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
        if (strcmp(PP.is_complex,'1'))
            code_lines{aa}=strrep(code_lines{aa},'$underscore_complex$','_complex');
        else
            code_lines{aa}=strrep(code_lines{aa},'$underscore_complex$','');
        end;
        code_lines{aa}=strrep(code_lines{aa},'$pname$',PP.pname);
        code_lines{aa}=strrep(code_lines{aa},'$dimensions$',dimensions);
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
