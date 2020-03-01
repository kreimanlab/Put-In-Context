clear all; close all; clc;


load('Mat/mturk_expA_GTlabel.mat');
TotalNumImg = 2259;
MaxSubj = length(mturkData);
GT = cell(TotalNumImg,MaxSubj);

for i = 1:length(mturkData)
    ans = mturkData(i).answer;
    responseList = extractfield(ans,'response');
    
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
        if length(find(strcmp(forbidden{f},responseList)))>10
            counter = 1;
            break;
        end
    end    
    if counter>0
        continue;
    end
    
    %check forbidden word repeating more than 10 times; discard
    %subjects
    forbidden = {'unknown',' don''t','no','none','idk','dontknow','bullshit','clueless','nothing','sth'};
    counter = 0;
    for f= 1:length(forbidden)
        counter = counter + length(find(strcmp(forbidden{f},responseList)));
    end    
    if counter>5
        continue;
    end
    
    %check if the subject has not provided more than 10 answers; discard
    %subjects
    if length(ans) <10
        continue;
    end
    
    for j = 1:length(ans)
        
        if length(ans(j).response)<3
            continue;
        end
        counter = 0;
        forbidden = {' don''t','no','none','idk','dontknow','bullshit','clueless','nothing','sth','unknown'};
        for f= 1:length(forbidden)
            if strcmp(forbidden{f},ans(j).response)
                counter = 1;
                break;
            end
        end 
        if counter == 1
            continue;
        end
        GT{ans(j).hit,i} = ans(j).response;       
    end
end

%combine array together
GTmturk = cell(TotalNumImg,1);
load('/home/mengmi/Projects/Proj_context2/Matlab/ImageStatsHuman_val_50_filtered.mat');

for i = 1: TotalNumImg
    contstr = {};
    
    for j = 1:MaxSubj
        str = GT{i,j};
        if isempty(str)
            continue;
        end
        contstr = [contstr str];
    end
    str1 = strtrim(ImageStatsFiltered(i).classname);
    str1(isspace(str1)) = [];
%     str2 = strtrim(comp_ground_truth{3}{i});
%     str2(isspace(str2)) = [];
    
    contstr = [contstr str1];
%     contstr = [contstr str2];
    GTmturk{i} = unique(contstr);
end

%group all ground truth labels with the same category
% cateinfor = extractfield(ImageStatsFiltered,'classlabel');   
% total = {};
% uniquecate = unique(cateinfor);
% for u = 1:length(uniquecate)
%     ind = find(cateinfor == uniquecate(u));
%     cateind = GTmturk(ind);
%     combined = cat(2,cateind{:});
%     combined=  unique(combined);
%     %GTmturk{ind} = combined;
%     for i = 1: length(ind)
%         GTmturk{ind(i),1} = combined;
%     end
% end

save(['Mat/mturk_expA_GTlabel_compiled.mat'],'GTmturk');



