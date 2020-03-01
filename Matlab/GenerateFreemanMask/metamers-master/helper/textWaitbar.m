function back = textWaitbar(back,percent)

%
%-----------------------------------------
% back = textWaitbar(varagin)
%
% init: T=text_waitbar('Text');
%
% use: T=text_waitbar(T,percent);
% 
% example:
%       T=text_waitbar('Text');
%       for i=1:200
%          T=text_waitbar(T,i/200);
%          pause(.03)
%       end
%
% freeman, from greschner, 1/10/2012
%-----------------------------------------

switch nargin
    case 0
        s=['\n|' repmat('-',1,48) '|\n'];
        fprintf(s);
        back=0;

    case 1
        text=back;
        if length(text)>46
            text=text(1:46);
        end
        s=['\n|-' text repmat('-',1,50-length(text)-3) '|\n'];
        fprintf(s);
        back=0;

    otherwise
        for i=1:floor(percent*50)-back
            fprintf('.');
            back=floor(percent*50);
        end

        if percent==1
            fprintf('\n\n');
        end
end