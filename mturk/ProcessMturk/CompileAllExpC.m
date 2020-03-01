clear all; close all; clc;
load(['/home/mengmi/Projects/Proj_context2/Matlab/ImageStatsHuman_val_50_filtered.mat']);
classList = extractfield(ImageStatsFiltered,'classlabel');
objList = extractfield(ImageStatsFiltered,'objIDinCate');
binList = extractfield(ImageStatsFiltered,'bin');

%match humans to gt labels
load('Mat/humanlabel.mat','HumanLabel');
load(['/home/mengmi/Projects/Proj_context2/pytorch/wordProcess/matchID.mat']);

load(['Mat/mturk_expA_GTlabel_compiled.mat']);

expname = 'expC';
load(['Mat/mturk_' expname '.mat']);
TotalNumImg = 80;
MaxSubj = length(mturkData);
classlabelSet = 4;
TotalTrialNumSet = 330;

%store infor about cate, type
startingMturkData = 1;

for i = startingMturkData:length(mturkData)
    ans = mturkData(i).answer;
    %check if the subject has not provided more than 10 answers; discard
    %subjects
    if length(ans) <TotalNumImg
        continue;
    end
    
    responseList = extractfield(ans,'response');
    responseList = lower(responseList);
    
    %check words with 1 or 2 letters for a word more than 10 times; discard
    %subjects
    lenList = cellfun(@(x){length(x)},responseList);
    lenList = cell2mat(lenList);
    if length(find(lenList<3))>5
        continue;
    end
    
    %check repetitions of single words more than 10 times; discard
    %subjects
    forbidden = unique(responseList);
    counter = 0;
    for f= 1:length(forbidden)
        if length(find(strcmp(forbidden{f},responseList)))>5
            counter = 1;
            break;
        end
    end    
    if counter>0
        continue;
    end
    
    %check forbidden word repeating more than 5 times; discard
    %subjects
    forbidden = {'toosmall','Toosmall','glitched','unsure','unknown',' don''t','no','none','idk','dontknow','bullshit','clueless','nothing','sth','error'};
    counter = 0;
    for f= 1:length(forbidden)
        counter = counter + length(find(strcmp(forbidden{f},responseList)));
    end    
    if counter>5
        continue;
    end
    
    
    type = ans(1).counterbalance;
    
    %infor = [i binL(i) cateL(i) imgL(i) typeL(i)];
    %load(['/home/mengmi/Projects/Proj_context2/mturk/Mturk/StimulusBackUp/expA_what/mturk_set' num2str(type) '/infor.mat']);
    infor = importdata(['/home/mengmi/Projects/Proj_context2/Matlab/' expname '_qr_classlabel/mturkSet_' num2str(type) '.txt']);
    infor = reshape(infor, classlabelSet, TotalTrialNumSet)';
    for j = 1:length(ans)
        vec = infor(ans(j).hit,:);
        vec_bin = vec(1);
        vec_cate = vec(2);
        vec_obj = vec(3);
        indimg = find(classList == vec_cate & objList == vec_obj & binList == vec_bin);
        gt  = GTmturk{indimg};        
        res = ans(j).response;
        
        flag = 0;
        if length(res)<3
            correct = nan;
            flag = 1;
        end
        counter = 0;
        forbidden = {' don''t','no','none','idk','dontknow','bullshit','clueless','nothing','sth','unknown','error'};
        for f= 1:length(forbidden)
            if strcmp(forbidden{f},res)
                counter = 1;
                break;
            end
        end 
        if counter == 1
            correct = nan;
            flag = 1;
        end
        
        if flag == 0
            if fcn_spellcheck(res, gt)==1 | strcmp(res, gt)==1
            %if strcmp(res, gt)
                correct = 1;
            else
                correct = 0;
            end
        end
        
        res = responseList{j};
        res = strrep(res,' ','');
        [a ind] = find(strcmp(HumanLabel,res)); 
        
        if isempty(ind)
            error('how come');
        end
        
        mturkData(i).answer(j).predLabel = matchID(ind);
        
        mturkData(i).answer(j).gt = gt;
        mturkData(i).answer(j).bin = vec_bin;
        mturkData(i).answer(j).cate = vec_cate;
        mturkData(i).answer(j).obj = vec_obj;
        mturkData(i).answer(j).type = vec(4);
        mturkData(i).answer(j).correct = correct;
       
    end
end


save(['Mat/mturk_' expname '_compiled.mat'],'mturkData');

