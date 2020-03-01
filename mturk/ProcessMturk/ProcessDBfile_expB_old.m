system('sqlite3 -header -csv db/expB.db "select * from expB;" > csv/results_expB.csv');

fid = fopen('csv/results_expB.csv');
out = textscan(fid,'%s');
strtotal = out{1,1};
pattern = ',""trialdata"":{""phase"":""TEST"",""imageID"":""';
pattern2= ',live,"{""';
pattern3 = ',""counterbalance"":';
mturkData = [];

for i = 1:length(strtotal)

    str = strtotal{i,1};    
    k = strfind(str,pattern);
    q = strfind(str,pattern2);
    if isempty(k) || isempty(q)
        continue;
    end
    
    answer = [];    
    %token = strtok(str,'""');
    %C = strsplit(str,'""phase"":""TEST""');
    C = strsplit(str,'{""uniqueid"":""');
    C=C';
    
    for j = 1:length(C)
        
        D = C{j,1};
        
        k = strfind(D,pattern);
        q = strfind(D,pattern3);
    
        if isempty(k) || isempty(q)
            continue;
        end
        
        datastring = strsplit(D,'"",""current_trial"":');
        datastringcopy = datastring{1,1};
        datastringcopy= strsplit(datastringcopy,':');
        workerid = datastringcopy{1,1};
        assignmentid = datastringcopy{1,2};

        datastring = strsplit(datastring{1,2},',""dateTime"":');
        datastring = strsplit(datastring{1,2},',""trialdata"":{""phase"":""TEST"",""imageID"":""');
        datastring = strsplit(datastring{1,2},'"",""response"":""');
        imageID=datastring{1,1};

        datastring = strsplit(datastring{1,2},'"",""hit"":');
        response = lower(datastring{1,1});
        response = spellcheck(response);
        %response

        datastring = strsplit(datastring{1,2},',""counterbalance"":');
        hit = str2num(datastring{1,1});

        datastring = strsplit(datastring{1,2},',""rt"":');
        counterbalance = str2num(datastring{1,1});

        datastring = strsplit(datastring{1,2},',""trial"":');
        rt = str2num(datastring{1,1});

        datastring = strsplit(datastring{1,2},'}},');
        trial = str2num(datastring{1,1});
        
        ans.workerid = workerid;
        ans.assignmentid = assignmentid;
        ans.imageID = imageID;
        ans.response = response;
        ans.hit = hit+1;
        ans.counterbalance = counterbalance;
        ans.rt = rt;
        ans.trial = trial;
        
        answer = [answer ans];
        
    end
    
    subj.workerid = ans.workerid;
    subj.assignmentid = assignmentid;
    subj.numhits = length(answer);
    subj.answer = answer;
    
    mturkData = [mturkData subj];
end

fclose(fid);
save('Mat/mturk_expB.mat','mturkData');