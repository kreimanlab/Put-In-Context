clear all; close all; clc;

foldername = 'Processed';

resulttextfolder = 'results_mturk_timing';

%datacursormode on;
videolist = dir([resulttextfolder '/*.txt']);

for video = 1:length(videolist)
      
    postfix = videolist(video).name(end-3:end);
    prefix = videolist(video).name(1:end-4);
    
    display(['Processing video #' num2str(video) '; video name: ' prefix]);
    
    %count how many times of QR detections
    textsave = [resulttextfolder '/' prefix '.txt'];
    fid = fopen(textsave);
    linecount = 1;
    tline = fgetl(fid);
    while ischar(tline)
        %disp(tline)
        tline = fgetl(fid);
        linecount = linecount + 1;
    end
    fclose(fid);
    
    if linecount >= 10
        continue;        
    end  
    
    % try without imrotate one more time
    videofilename = ['/home/mengmi/Dropbox/Mengmi/' foldername '/' prefix  '.mp4'];
    
    if exist(videofilename, 'file') ~= 2
        videofilename = ['/home/mengmi/Dropbox/Mengmi/' foldername '/' prefix  '.MP4'];
    end 
    
    display(['generating frames']);
    vidObj = VideoReader(videofilename);
    mkdir(['temp']);
    counter = 0;
    firstFrame = 0;
    while hasFrame(vidObj)
        frame = readFrame(vidObj);
        if counter <10
            imshow(frame);
            pause;
        end
        counter = counter + 1;

        %angle = 180;
        %frame = imrotate(frame,angle);
        %imshow(frame);
        imwrite(frame, ['temp/frame_' num2str(counter) '.jpg']);
    end   
    
    display(['decoding QR code on frames']);
    
    totalnum = counter;
    textsave = [resulttextfolder '/' prefix '.txt'];
    command = ['java -cp qr_code/qrdecode_java/examples/examples.jar boofcv.examples.fiducial.ExampleDetectQrCode ' ...
        textsave ' ' num2str(totalnum)];
        
    [status,cmdout] = system(command);  
    
    
    %count how many times of QR detections
    textsave = [resulttextfolder '/' prefix '.txt'];
    fid = fopen(textsave);
    linecount = 1;
    tline = fgetl(fid);
    while ischar(tline)
        %disp(tline)
        tline = fgetl(fid);
        linecount = linecount + 1;
    end
    fclose(fid);
    
    if linecount <10
        warning(['this video is bad; nothing we can do; move video to bad folder']);
        
        command = ['mv ' textsave  ' /home/mengmi/Dropbox/Mengmi/Bad/' prefix '.txt'];
        [status,cmdout] = system(command);
        
        format = '.mp4';
        videoallfilename = ['/home/mengmi/Dropbox/Mengmi/' foldername '/' prefix format];
        if exist(videofilename, 'file') == 2
            command = ['mv ' '"/home/mengmi/Dropbox/Mengmi/' foldername '/' prefix format '"'  ' /home/mengmi/Dropbox/Mengmi/Bad/' prefix format];
            [status,cmdout] = system(command);
        end
        
        format = '.MP4';
        videoallfilename = ['/home/mengmi/Dropbox/Mengmi/' foldername '/' prefix format];
        if exist(videofilename, 'file') == 2
            command = ['mv ' '"/home/mengmi/Dropbox/Mengmi/' foldername '/' prefix format '"'  ' /home/mengmi/Dropbox/Mengmi/Bad/' prefix format];
            [status,cmdout] = system(command);
        end
        
        format = '.mov';
        videoallfilename = ['/home/mengmi/Dropbox/Mengmi/' foldername '/' prefix format];
        if exist(videofilename, 'file') == 2
            command = ['mv ' '"/home/mengmi/Dropbox/Mengmi/' foldername '/' prefix format '"'  ' /home/mengmi/Dropbox/Mengmi/Bad/' prefix format];
            [status,cmdout] = system(command);
        end
        
        format = '.MOV';
        videoallfilename = ['/home/mengmi/Dropbox/Mengmi/' foldername '/' prefix format];
        if exist(videofilename, 'file') == 2
            command = ['mv ' '"/home/mengmi/Dropbox/Mengmi/' foldername '/' prefix format '"'  ' /home/mengmi/Dropbox/Mengmi/Bad/' prefix format];
            [status,cmdout] = system(command);
        end
    end  
    
    
    display('done');
end