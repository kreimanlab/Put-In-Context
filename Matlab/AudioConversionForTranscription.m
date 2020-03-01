clear all; close all; clc;

folderlist = {'audio_expG','audio_expG','audio_expG','audio_expG','audio_expG','audio_expG','audio_expG','audio_expG'};%,'audio_expB'}; %'audio_expB','audio_expF'
subjectlist = {'subj02-km','subj03-wr','subj04-ah','subj05-mg','subj06-cl','subj07-cs','subj08-er','subj09-ma'};

WriteDir = '/home/mengmi/Desktop/';

for f = 1:length(folderlist)
    
    display(['processing audio: ' folderlist{f} '/ ' subjectlist{f} ]);
    
    WriteFolderPath = [WriteDir folderlist{f} '_mp3'];
    mkdir(WriteFolderPath);
    mkdir([WriteFolderPath '/' subjectlist{f}]);
    audiolist = dir([folderlist{f} '/' subjectlist{f} '/audio/trial_audio_*.mat']); 
    
    for audio = 1:length(audiolist)
        load([folderlist{f} '/' subjectlist{f} '/audio/' audiolist(audio).name ]);
        Fs = 8192; %audio sample rate
        
        audiofilename = [WriteFolderPath '/' subjectlist{f} '/' audiolist(audio).name(1:end-4) '.wav'];
        audiowrite(audiofilename,myaudio.audiodata,Fs);
    end
end
    