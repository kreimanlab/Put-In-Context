clear all; close all; clc;

expnamelist = {'expC','expD','expE','expG','expH'};
expnamesetnumlist = [1200 1500 600 2000 400];
TotalTrialNumSetlist = [330 440 330 330 440];

expnamelist = expnamelist(3:end);
expnamesetnumlist = expnamesetnumlist(3:end);
TotalTrialNumSetlist = TotalTrialNumSetlist(3:end);

classlabelSet = 4;

for E = 1:length(expnamelist)

    expname = expnamelist{E};
    expnamesetnum = expnamesetnumlist(E);
    TotalTrialNumSet = TotalTrialNumSetlist(E);

    for n = 1:expnamesetnum

        infor = importdata(['/home/mengmi/Projects/Proj_context2/Matlab/' expname '_qr_classlabel/mturkSet_' num2str(n) '.txt']);
        infor = reshape(infor, classlabelSet, TotalTrialNumSet)';

        for t = 1:TotalTrialNumSet
            display(['checking: ' expname '; file number: ' num2str(n) '; trial: ' num2str(t)]);
            gifname = ['/media/mengmi/DATA/Projects/Proj_Context2/Stimulus/keyframe_' expname '_gif/bin' num2str(infor(t,1)) '/gif_' num2str(infor(t,1)) '_' num2str(infor(t,2)) '_' num2str(infor(t,3)) '_' num2str(infor(t,4)) '.gif'];
            if exist(gifname, 'file') ~= 2
                
                if strcmp(expname, 'expE') && infor(t,4)>4
                    continue;
                elseif strcmp(expname, 'expG') && infor(t,4)>12
                    continue;
                elseif strcmp(expname, 'expH') && infor(t,4)>2
                    continue;
                else
                    error(['gif not exists: ' gifname]);
                end
                    
            end
        end

    end

end