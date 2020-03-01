function JigSaw
% written by Lindo Ouseph
% Research scholar, Department of Electronics,CUSAT,Kochi,India
% Jigsaw puzzle
close all;clc
global status h s D1 m Im
status=0;
% [file path]=uigetfile('*');
% Im=imread([path,file]);
Im=imread('Albert_Einstein.jpg');
% m=input('Partitions : ');
m=4;
s=size(Im);
dr=floor(s(1)/m);dc=floor(s(2)/m);
for i=1:m
    for j=1:m
        D{i,j}=Im(dr*(i-1)+1:dr*i,dc*(j-1)+1:dc*j,:);
    end
end
R=rand(m^2,1);[V,I]=sort(R);D1=D;
for i=1:length(I);D1{i}=D{I(i)};end
h.f=figure('menubar','none',...
    'numbertitle','off',...
    'paperunit','points',...
    'name','Jigsaw',...
    'PaperSize',[s(1),s(2)],...
    'PaperUnits','points',...
    'WindowButtonDownFcn',@Down,...
    'WindowButtonUpFcn',@Up,...
    'WindowButtonMotionFcn',@Motion);

h.im=imshow(cell2mat(D1));
h.a=get(h.im,'parent');
p=get(h.f,'position');
set(h.f,'position',[0 0 s(2) s(1)]);
set(h.a,'position',[0 0 1 1])
%--------------------------------------------------------------------------
function Down(varargin)
global status x1 y1 s h m
status=1;
p=get(h.f,'currentpoint');
c=p(1);
r=s(1)-p(2);
if r>0 && c>0 && r<=s(1) && c<=s(2)
    x1=ceil(r/(s(1)/m));
    y1=ceil(c/(s(2)/m));
    if x1==m+1;x1=m;end
    if y1==m+1;y1=m;end
end
%--------------------------------------------------------------------------
function Up(varargin)
global status x1 y1 x2 y2 s h m D1
status=0;
p=get(h.f,'currentpoint');
c=p(1);
r=s(1)-p(2);
if r>0 && c>0 && r<=s(1) && c<=s(2)
    x2=ceil(r/(s(1)/m));
    y2=ceil(c/(s(2)/m));
    if x2==m+1;x2=m;end
    if y2==m+1;y2=m;end
end
temp=D1{x1,y1};
D1{x1,y1}=D1{x2,y2};
D1{x2,y2}=temp;
set(h.im,'cdata',(cell2mat(D1)));
set(h.a,'position',[0 0 1 1]);drawnow
%--------------------------------------------------------------------------
function Motion(varargin)
global status x1 y1 s h m D1 im im1 im2
if status
    im=cell2mat(D1);
    im1=im;
    clc
    p=get(h.f,'currentpoint');
    r=s(1)-p(2);
    c=p(1);
    if r>0 && c>0 && r<=s(1) && c<=s(2)
        x=ceil(r/(s(1)/m));
        y=ceil(c/(s(2)/m));
        if x==m+1;x=m;end
        if y==m+1;y=m;end
    end
    try im2=im(floor((x1-1)*s(1)/m+1):floor(x1*s(1)/m),floor((y1-1)*s(2)/m+1):floor(y1*s(2)/m),:);end
    [p q w]=size(im2);
    if ((r>=p/2) && (c>=q/2) && (r<=s(1)-p/2) && (c<=s(2)-q/2))
        try
            im1(floor(r-p/2:r+p/2-1),floor(c-q/2:c+q/2-1),:)=im2;
            set(h.im,'cdata',im1);
%             imshow(im1);
            set(h.a,'position',[0 0 1 1]);drawnow
        end
    end
end
%--------------------------------------------------------------------------