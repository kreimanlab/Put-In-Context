clear all; close all; clc;

explist = {'expB','expC','expD','expE','expG','expH'};

for ex = 1:length(explist)
    
    expname = explist{ex};

    testlist = dir(['results_mturk_timing/*.txt']);
    %tlistL = [];

    messageToSearch = [' message: ' expname '_trial_'];
    mturkTime = [];
    
    for t = 1: length(testlist)
        
        display(['processing ' expname ' for text file: ' testlist(t).name ]);
        fileID = fopen(['results_mturk_timing/' testlist(t).name] ,'r');

        %% read in text strings
        str = {};
        tline = fgetl(fileID);
        while ischar(tline)
            %disp(tline);
            str = [str tline];
            tline = fgetl(fileID);
        end
        fclose(fileID);

        %% extract worker id and assignmentid
        uniqueid = str{1};
        a = strsplit(uniqueid,'message: ');
        a = strsplit(a{2},':');
        
        if length(a)~=2
            continue;
        end
        
        workerid = a{1};
        assignmentid = a{2};
        
        %% extract type and frame
        framelist = [];
        frametyelist  =[];
        trialtypelist = [];

        for i = 1:length(str)
            a = str{i};
            b = strsplit(a,'frame: ');

            f = strsplit(b{2}, messageToSearch); % *_type_');
            if length(f) == 1
                continue;
            end

            framelist = [framelist str2num(f{1})];
            g = strsplit(f{2}, '_type_'); % *_type_');
            frametyelist = [frametyelist str2num(g{2})];
            
            trialinfor = strsplit(g{1},'_');
            trialtypelist = [trialtypelist  str2num(trialinfor{4})];
            %triallist = [triallist str2num(g{1})];
        end
        
        if length(framelist) == 0
            continue;
        end

        %% process the time interval
        startlist = []; elist =[]; trialtyperec = [];
        remem = -1;
        for i = 2:length(framelist)
            if frametyelist(i) == 3 && remem == -1 && abs(framelist(i-1) - framelist(i)) == 1
                remem = framelist(i);
                startlist = [startlist framelist(i)];
                trialtyperec = [trialtyperec trialtypelist(i)];
                
            elseif frametyelist(i) ~=3 && remem > 0 && abs(framelist(i-1) - framelist(i)) == 1
                remem = -1;
                elist = [elist framelist(i)];
            end  

        end

        if length(elist) < length(startlist)
            startlist = startlist(1:length(elist));
            trialtyperec = trialtyperec(1:length(elist));
        else
            elist = elist(1:length(startlist));
        end
        diff = elist - startlist;

        % get their frame rates
        prefix = testlist(t).name(1:end-4);
        videofilename = ['/home/mengmi/Dropbox/Mengmi/Processed/' prefix '.mp4'];
        
        if exist(videofilename, 'file') ~= 2
            videofilename = ['/home/mengmi/Dropbox/Mengmi/Processed/' prefix '.MP4'];
        end
        command = ['ffprobe -v 0 -of csv=p=0 -select_streams v:0 -show_entries stream=r_frame_rate ' videofilename];
        [status,cmdout] = system(command);
        %vidObj = VideoReader(videofilename);

        %fR = vidObj.FrameRate;
        fR = str2num(cmdout);
        %clear vidObj;
        tlist = (diff+1)*1000/fR;
        
        %hist(tlist);
        %ylim([0 35]);
        %pause;
        %tlistL = [tlistL tlist];
        
        mt.timediff = tlist;
        mt.videorate = fR;
        mt.trialtyperec = trialtyperec; 
        mt.workerid = workerid;
        mt.assignmentid = assignmentid;
        
        mturkTime = [mturkTime mt];
    end
    
    save(['results_mturk_timing_mat/' expname '_timing.mat'],'mturkTime');
end

% binranges = [20:10:300];
% bincounts = histc(tlistL,binranges);
% linewidth = 3;
% plot(binranges, bincounts/sum(bincounts),'k-','LineWidth',linewidth);
% xlabel('Stimulus Presentation Time (ms)','FontSize', 11);
% ylabel('Distribution','FontSize', 11);
% %title('In-lab','FontSize', 11)
% xlim([20 300]);
% hold on;
% plot(ones(1,11)*200, [0:0.1:1],'k--');
%legend({'Subj1', 'Subj2', 'Subj3', 'Subj4', 'Subj5','All'},'Location','northeast','FontSize',10);







