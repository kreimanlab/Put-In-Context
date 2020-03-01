clear all; close all; clc;

load('/home/mengmi/Projects/Proj_context2/Matlab/ImageStatsHuman_val_50_filtered.mat');
expname = 'expA';

listcate = [68 66 65 65 60 9];
listobjid = [3 7 13 9 26 1];

for i = 1:length(listcate)
    
    %infor = ImageStatsFiltered(i);
    vec_bin = 3;
    vec_cate = listcate(i);
    vec_img = listobjid(i);
    
    if vec_bin <= 2
        continue;
    end
    
    stimuliname = ['trial_' num2str(vec_bin) '_'  num2str(vec_cate)  '_' num2str(vec_img) '_screen2_imgtype_8.jpg'];
    stimuli = imread(['/home/mengmi/Projects/Proj_context2/Matlab/Stimulus/keyframe_' expname '/' stimuliname]);
    imwrite(stimuli, ['/home/mengmi/Desktop/selectedfig2/expA_' stimuliname ]);
    
    stimuliname = ['trial_' num2str(vec_bin) '_'  num2str(vec_cate)  '_' num2str(vec_img) '_screen2_imgtype_2.jpg'];
    stimuli = imread(['/home/mengmi/Projects/Proj_context2/Matlab/Stimulus/keyframe_' expname '/' stimuliname]);
    imwrite(stimuli, ['/home/mengmi/Desktop/selectedfig2/expA_' stimuliname ]);
    
    stimuliname = ['trial_' num2str(vec_bin) '_'  num2str(vec_cate)  '_' num2str(vec_img) '_screen2_imgtype_5.jpg'];
    stimuli = imread(['/home/mengmi/Projects/Proj_context2/Matlab/Stimulus/keyframe_' expname '/' stimuliname]);
    imwrite(stimuli, ['/home/mengmi/Desktop/selectedfig2/expA_' stimuliname ]);
    
    filename = ['trial_' num2str(vec_bin) '_'  num2str(vec_cate)  '_' num2str(vec_img) '_PortillaMask.jpg'];
    filename1 = ['/home/mengmi/Projects/Proj_context2/Matlab/Stimulus/keyframe_expB/' filename];
    if exist(filename1, 'file') ~= 2
         continue;
    end
    stimuli = imread(filename1);
    imwrite(stimuli, ['/home/mengmi/Desktop/selectedfig2/expB_' filename ]);
    
%     filename = ['trial_' num2str(vec_bin) '_'  num2str(vec_cate)  '_' num2str(vec_img) '_screen2_imgtype_1.jpg'];
%     filename1 = ['/home/mengmi/Projects/Proj_context2/Matlab/Stimulus/keyframe_expE/' filename];
%     if exist(filename, 'file') ~= 2
%          continue;
%     end
%     stimuli = imread(filename1);
%     imwrite(stimuli, ['/home/mengmi/Desktop/selectedfig2/expE_' filename ]);
    
    filename = ['trial_' num2str(vec_bin) '_'  num2str(vec_cate)  '_' num2str(vec_img) '_screen2_imgtype_2.jpg'];
    filename1 = ['/home/mengmi/Projects/Proj_context2/Matlab/Stimulus/keyframe_expE/' filename];
    if exist(filename1, 'file') ~= 2
         continue;
    end
    stimuli = imread(filename1);
    imwrite(stimuli, ['/home/mengmi/Desktop/selectedfig2/expE_' filename ]);
    
    filename = ['trial_' num2str(vec_bin) '_'  num2str(vec_cate)  '_' num2str(vec_img) '_6_blur.jpg'];
    filename1 = ['/home/mengmi/Projects/Proj_context2/Matlab/Stimulus/keyframe_expC/' filename];
    if exist(filename1, 'file') ~= 2
         continue;
    end
    stimuli = imread(filename1);
    imwrite(stimuli, ['/home/mengmi/Desktop/selectedfig2/expC_' filename ]);
    
    filename = ['trial_' num2str(vec_bin) '_'  num2str(vec_cate)  '_' num2str(vec_img) '_6_blur.jpg'];
    filename1 = ['/home/mengmi/Projects/Proj_context2/Matlab/Stimulus/keyframe_expD/' filename];
    if exist(filename1, 'file') ~= 2
         continue;
    end
    stimuli = imread(filename1);
    imwrite(stimuli, ['/home/mengmi/Desktop/selectedfig2/expD_' filename ]);
    
    filename = ['trial_' num2str(vec_bin) '_'  num2str(vec_cate)  '_' num2str(vec_img) '_screen2_imgtype_4.jpg'];
    filename1 = ['/home/mengmi/Projects/Proj_context2/Matlab/Stimulus/keyframe_expE/' filename];
    if exist(filename1, 'file') ~= 2
         continue;
    end
    stimuli = imread(filename1);
    imwrite(stimuli, ['/home/mengmi/Desktop/selectedfig2/expE_' filename ]);
    
    filename = ['trial_' num2str(vec_bin) '_'  num2str(vec_cate)  '_' num2str(vec_img) '_screen2_imgtype_1.jpg'];
    filename1 = ['/home/mengmi/Projects/Proj_context2/Matlab/Stimulus/keyframe_expH/' filename];
    if exist(filename1, 'file') ~= 2
         continue;
    end
    stimuli = imread(filename1);
    imwrite(stimuli, ['/home/mengmi/Desktop/selectedfig2/expH_' filename ]);
    
    filename = ['trial_' num2str(vec_bin) '_'  num2str(vec_cate)  '_' num2str(vec_img) '_screen2_imgtype_2.jpg'];
    filename1 = ['/home/mengmi/Projects/Proj_context2/Matlab/Stimulus/keyframe_expH/' filename];
    if exist(filename1, 'file') ~= 2
         continue;
    end
    stimuli = imread(filename1);
    imwrite(stimuli, ['/home/mengmi/Desktop/selectedfig2/expH_' filename ]);
    
end