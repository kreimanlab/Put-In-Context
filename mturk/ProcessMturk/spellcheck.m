function [response] = spellcheck(word)
% input must be a word

%word = 'skis';
inputfile = ['temp' num2str(randi(10)) '.txt'];
outputfile = ['error' num2str(randi(10)) '.txt'];
fid = fopen(inputfile,'wt');
fprintf(fid, word);
fclose(fid);
system(['ispell -a < ' inputfile ' > ' outputfile]);
fid = fopen(outputfile);
line = fgetl(fid); %the first line is useless; discard 
line = fgetl(fid); %use the second line
fclose(fid);
if strcmp('*',line)
    response = word;
    %display('correct');
else
    C = strsplit(line,':');
    if length(C) <2
        response = word;
    else
        C = strsplit(C{2},',');
        response = C{1};
    end
    %display(response);
end

%system(['rm ' inputfile]);
%system(['rm ' outputfile]);
