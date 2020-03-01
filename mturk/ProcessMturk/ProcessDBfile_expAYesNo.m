system('sqlite3 -header -csv db/expA_YesNo.db "select * from expA_YesNo_short;" > csv/results_expA_YesNo.csv');

pattern = ',"trialdata":{"phase":"TEST","imageID":"';
pattern2= ',live,"{""';
pattern3 = ',"counterbalance":';
mturkData = [];

% note that I have to manually copy and paste to form text file due to
% space
fid = fopen('csv/results_expA_YesNo.txt');

tline = fgetl(fid);
while ischar(tline)
    
    tline(isspace(tline)) = [];
    str = tline;
%     k = strfind(str,pattern);
%     q = strfind(str,pattern2);
%     if isempty(k) || isempty(q)
%         continue;
%     end
    
    answer = [];    
    %token = strtok(str,'""');
    %C = strsplit(str,'""phase"":""TEST""');
    C = strsplit(str,'{"uniqueid":"');
    C=C';
    
    for j = 1:length(C)
        
        D = C{j,1};
        
        k = strfind(D,pattern);
        q = strfind(D,pattern3);
    
        if isempty(k) || isempty(q)
            continue;
        end
        
        datastring = strsplit(D,'","current_trial":');
        datastringcopy = datastring{1,1};
        datastringcopy= strsplit(datastringcopy,':');
        workerid = datastringcopy{1,1};
        assignmentid = datastringcopy{1,2};

        datastring = strsplit(datastring{1,2},',"dateTime":');
        datastring = strsplit(datastring{1,2},',"trialdata":{"phase":"TEST","imageID":"');
        datastring = strsplit(datastring{1,2},'","response":"');
        imageID=datastring{1,1};

        datastring = strsplit(datastring{1,2},'","hit":');
        response = str2num(datastring{1,1});

        datastring = strsplit(datastring{1,2},',"counterbalance":');
        hit = str2num(datastring{1,1});

        datastring = strsplit(datastring{1,2},',"rt":');
        counterbalance = str2num(datastring{1,1});
        
        datastring = strsplit(datastring{1,2},',"choicelist":');
        rt = str2num(datastring{1,1});
        
        datastring = strsplit(datastring{1,2},',"choicename":');
        choicelist = str2num(datastring{1,1});
        
        datastring = strsplit(datastring{1,2},',"gtlab":');
        choicename = (datastring{1,1});

        datastring = strsplit(datastring{1,2},',"gtname":"');
        gtlab = str2num(datastring{1,1});
        
        datastring = strsplit(datastring{1,2},'","trial":');
        gtname = (datastring{1,1});
        
        datastring = strsplit(datastring{1,2},'}},');
        trial = str2num(datastring{1,1});
        
        ans.workerid = workerid;
        ans.assignmentid = assignmentid;
        ans.imageID = imageID;
        ans.response = response;
        ans.hit = hit;
        ans.type = counterbalance;
        ans.rt = rt;
        ans.choicelist = choicelist;
        ans.choicename = choicename;
        ans.gtlab = gtlab;
        ans.gtname = gtname;
        ans.trial = trial;
        
        answer = [answer ans];
        
    end
    
    subj.workerid = ans.workerid;
    subj.assignmentid = assignmentid;
    subj.numhits = length(answer);
    subj.answer = answer;
    
    mturkData = [mturkData subj];
    tline = fgetl(fid);
end
display('done processing');
fclose(fid);
save('Mat/mturk_expA_YesNo.mat','mturkData');