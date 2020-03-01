clear all; close all; clc;
load(['/home/mengmi/Projects/Proj_context2/Matlab/ImageStatsHuman_val_50_filtered.mat']);
classList = extractfield(ImageStatsFiltered,'classlabel');
objList = extractfield(ImageStatsFiltered,'objIDinCate');
binList = extractfield(ImageStatsFiltered,'bin');

load('Mat/mturk_expA_YesNo.mat');
TotalNumImg = 100;
MaxSubj = length(mturkData);

%store infor about cate, type
for i = 1:length(mturkData)
    ans = mturkData(i).answer;
    
    if length(ans) <TotalNumImg
        continue;
    end
    type = ans(1).type;
    
    %infor = [i binL(i) cateL(i) imgL(i) typeL(i)];
    load(['/home/mengmi/Projects/Proj_context2/mturk/Mturk/StimulusBackUp/expA_what/mturk_set' num2str(type) '/infor.mat']);
    
    for j = 1:length(ans)
        vec = infor(ans(j).hit,:);
        vec_bin = vec(2);
        vec_cate = vec(3);
        vec_obj = vec(4);
        indimg = find(classList == vec_cate & objList == vec_obj & binList == vec_bin);
               
        %tell whether the answer is correct or not
        res = ans(j).response;
        gtlab = ans(j).gtlab;
        choicelist = ans(j).choicelist;
        if choicelist == gtlab
            if res == 1
                correct = 1;
            else
                correct = 0;
            end
        else
            if res == 1
                correct = 0;
            else
                correct = 1;
            end
        end
        
        %mturkData(i).answer(j).gt = gt;
        mturkData(i).answer(j).bin = vec_bin;
        mturkData(i).answer(j).cate = vec_cate;
        mturkData(i).answer(j).obj = vec_obj;
        mturkData(i).answer(j).type = vec(5);
        mturkData(i).answer(j).correct = correct;
       
    end
end


save(['Mat/mturk_expA_YesNo_compiled.mat'],'mturkData');

