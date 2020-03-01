clear all; close all; clc;

%NOTES: %delete vis_2284.jpg before running

load(['ImageStatsHuman_val_50.mat']); 
invalidclasslabel = [];
validtrial = [];
BinNum = 4;

%find class label for each bin
for b = 1:BinNum
    
    imglist = dir(['../../temp/bin' num2str(b) '/vis_*']);
    nameIDmatch = extractfield(imglist,'name');
    imgnum_B1 = cellfun(@(nameIDmatch) sscanf(nameIDmatch,'vis_%d_') , nameIDmatch);
    validtrial = [validtrial imgnum_B1];
    ImgStatsB1 = ImageStats(imgnum_B1);
    classlabelB1 = extractfield(ImgStatsB1,'classlabel');
    for c = 1:71
        if length(find(classlabelB1 == c))<2
            invalidclasslabel = [invalidclasslabel c];
        end
    end

end
invalidclasslabel = unique(invalidclasslabel);
ImageStats = ImageStats(validtrial);
display('invalid class label extraction completed');

%generate the filtered image list
AccumulateFiltered = zeros(71,4);
ImageStatsFiltered = [];
for i = 1:length(ImageStats)
    node = ImageStats(i);
    if ~ismember(node.classlabel, invalidclasslabel)      
        
        AccumulateFiltered(node.classlabel,node.bin) = AccumulateFiltered(node.classlabel,node.bin) + 1;
        node.objIDinCate = AccumulateFiltered(node.classlabel,node.bin);
        ImageStatsFiltered = [ImageStatsFiltered node];
    end
end
display('ImageStatsFiltered completed');
%save(['ImageStatsHuman_val_50_filtered.mat'],'ImageStatsFiltered','AccumulateFiltered','invalidclasslabel');
display(['Total trial numbers: ' num2str( (71-length(invalidclasslabel))*2*4)]);



        