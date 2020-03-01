clear all; close all; clc;

foldername = 'Processed';
%foldername = 'PsiturkVideoStore';

%datacursormode on;
videolist = dir(['/home/mengmi/Dropbox/Mengmi/' foldername '/*']);
videolist = videolist(3:end);

resulttextfolder = 'results_mturk_timing';

for video = 1:length(videolist)
      
    postfix = videolist(video).name(end-3:end);
    prefix = videolist(video).name(1:end-4);
    
    display(['Processing video #' num2str(video) '; video name: ' prefix]);
    
    %rename if having space in videoname
    prefix(find(prefix ==' ')) = [];    
    command = ['mv ' '"/home/mengmi/Dropbox/Mengmi/' foldername '/' videolist(video).name '"'  ' /home/mengmi/Dropbox/Mengmi/' foldername '/' prefix postfix];
    [status,cmdout] = system(command);
    
    if exist([resulttextfolder '/' prefix '.txt'], 'file') == 2
        continue;
    end
    
    if strcmp( postfix, '.MOV') || strcmp(postfix , '.mov')
        
        if exist(['/home/mengmi/Dropbox/Mengmi/' foldername '/' prefix '.mp4'], 'file') ~= 2
             
            display(['converting .mov to .mp4']);
            command = ['ffmpeg -i /home/mengmi/Dropbox/Mengmi/' foldername '/' prefix postfix ...
                ' /home/mengmi/Dropbox/Mengmi/' foldername '/' prefix '.mp4'];

            [status,cmdout] = system(command);
            postfix = '.mp4';
        end
    end

    videofilename = ['/home/mengmi/Dropbox/Mengmi/' foldername '/' prefix  postfix];
    display(['generating frames']);
    vidObj = VideoReader(videofilename);
    mkdir(['temp']);
    counter = 0;
    firstFrame = 0;
    while hasFrame(vidObj)
        frame = readFrame(vidObj);
        if counter == 0
            firstFrame = frame;
        end
        counter = counter + 1;

        angle = 180;
        frame = imrotate(frame,angle);
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
    fid = fopen(textsave);
    linecount = 1;
    tline = fgetl(fid);
    while ischar(tline)
        %disp(tline)
        tline = fgetl(fid);
        linecount = linecount + 1;
    end
    fclose(fid);
    
    if linecount < 10
        warning(['less QR detection; check imshow(frame) for rotations']);
        warning(['wrong video name: ' videofilename]);
        imshow(firstFrame);
        %pause;
    end  
    
    display('done');
end