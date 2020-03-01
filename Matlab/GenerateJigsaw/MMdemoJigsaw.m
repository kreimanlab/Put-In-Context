close all;clc; clear all;

mw=6; %number of grids along y-axis (vertical)
mh = 8; %number of grids along x-axis (horizontal)

imgpath = '../WriteGIFKarla/data/'; %path for raw images
saveimgpath = '../WriteGIFKarla/Jigsaw/'; %save generated PortillaMask
imgorilist = dir([imgpath '*_Original.jpg']);
NumImg = length(imgorilist);

for imgnum = 1: NumImg

    display(['processing image number: ' num2str(imgnum) ]);
    
    imgorifullname = [imgpath imgorilist(imgnum).name ];
    im0 = imread(imgorifullname);	% im0 is a double float matrix!
    im0 = rgb2gray(im0);    
    sizeim0 = size(im0);
    
    Im = im0;
    s=size(Im);
    dr=floor(s(1)/mw);dc=floor(s(2)/mh);
    for i=1:mw
        for j=1:mh
            D{i,j}=Im(dr*(i-1)+1:dr*i,dc*(j-1)+1:dc*j,:);
        end
    end
    R=rand(mw*mh,1);[V,I]=sort(R);D1=D;
    for i=1:length(I);D1{i}=D{I(i)};end
    jigsaw = cell2mat(D1);
    %imshow(jigsaw);

    jigsaw = imresize(jigsaw,sizeim0);
    imwrite(jigsaw,[saveimgpath imgorilist(imgnum).name(1:end-13) '_jigsaw.jpg']);

end