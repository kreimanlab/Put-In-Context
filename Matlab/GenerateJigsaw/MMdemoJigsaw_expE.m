close all;clc; clear all;

load(['../ImageStatsHuman_val_50_filtered.mat']);

saveimgpath = ['../Stimulus/img_jigsaw/img_'];
saveimgpathbin = ['../Stimulus/binMask_jigsaw/bin_'];


mw=[2 4 8]; %number of grids along y-axis (vertical)
mh =[2 4 8]; %number of grids along x-axis (horizontal)

NumJigsawBins = length(mw);
NumImg = length(ImageStatsFiltered);

for imgnum = 1: NumImg

    display(['processing image number: ' num2str(imgnum) ]);
    node = ImageStatsFiltered(imgnum);
    
    imgorifullname = ['../Stimulus/img/img_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '.jpg' ];
    imgbinfullname = ['../Stimulus/binMask/bin_'  num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '.jpg'];
    
    im0 = imread(imgorifullname);	% im0 is a double float matrix!     
    sizeim0 = size(im0);
    sizeim1 = sizeim0(1:2);
    
    Im = im0;
    s=size(Im);
    
    % convert to binary image
    bin = imread(imgbinfullname);
    bin = imresize(bin,sizeim1);
    bin = im2bw(bin,0.5);
    
    for jig = 1:NumJigsawBins
        D = [];
        B = [];
        dr=floor(s(1)/mw(jig));dc=floor(s(2)/mh(jig));
        flag = 0;
        markx = 0;
        marky = 0;
        
        for i=1:mw(jig)
            for j=1:mh(jig)
                D{i,j}=Im(dr*(i-1)+1:dr*i,dc*(j-1)+1:dc*j,:);
                B{i,j}=bin(dr*(i-1)+1:dr*i,dc*(j-1)+1:dc*j,:);
                
                
                if flag == 0 && sum(sum(B{i,j})) > 0
                    flag = 1;
                    markx = i;
                    marky = j;
                elseif flag == 1 && sum(sum(B{i,j})) > 0
                    flag = 2;
                end
            end
        end
    
        if flag == 2
            continue;
        end
        
        I=randperm(mw(jig)*mh(jig),mw(jig)*mh(jig));
        
        pos = mw(jig)*(marky-1)+markx;
        ii = I(pos);
        I(find(I == pos)) = ii;
        I(pos) = pos;
        
        D1=D;
        B1=B;
        for i=1:length(I)
            D1{i}=D{I(i)};
            B1{i}=B{I(i)};
        end
        jigsaw = cell2mat(D1);
        jigsawbin = cell2mat(B1);
        %imshow(jigsaw);

        jigsaw = imresize(jigsaw,sizeim1);
        jigsawbin = imresize(jigsawbin,sizeim1);
        
%         subplot(1,2,1);imshow(jigsaw);
%         subplot(1,2,2);imshow(jigsawbin);
%         pause;
        
        imwrite(jigsaw,[saveimgpath num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(jig) '.jpg']);
        imwrite(jigsawbin, [saveimgpathbin num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(jig) '.jpg']);

    end

end