clear all; close all; close;

%% train

fileIDori = fopen('/home/mengmi/Projects/Proj_context2/Datalist/trainColor_oriimg.txt','w');
fileIDimg = fopen('/home/mengmi/Projects/Proj_context2/Datalist/trainColor_img.txt','w');
fileIDcrimg = fopen('/home/mengmi/Projects/Proj_context2/Datalist/trainColor_crimg.txt','w');
fileIDbinimg = fopen('/home/mengmi/Projects/Proj_context2/Datalist/trainColor_binimg.txt','w');
fileIDlabels = fopen('/home/mengmi/Projects/Proj_context2/Datalist/trainColor_label.txt','w');
% fileIDcateg = fopen('/home/mengmi/Proj/Proj_context/datalist/categ_trainlist.txt','w');

cateNum = 55;

for c = 1: cateNum
    c
    folderdir_img= ['/home/mengmi/Projects/Proj_context2/Datasets/MSCOCO/trainColor_oriimg/cate' sprintf( '%02d', c) '/ori_*.jpg'];
%     folderdir_crimg= ['/media/mengmi/TOSHIBABlue1/Proj_Context/Datasets/MSCOCO/train/cate' num2str(c) '/crimg_*.jpg'];
%     folderdir_categ= ['/media/mengmi/TOSHIBABlue1/Proj_Context/Datasets/MSCOCO/train/cate' num2str(c) '/categ_*.jpg'];
    imglist_img = dir(folderdir_img);
%     imglist_crimg = dir(folderdir_crimg);
%     imglist_categ = dir(folderdir_categ);
    
    for i = 1: length(imglist_img)
        
        if ~exist(['/home/mengmi/Projects/Proj_context2/Datasets/MSCOCO/trainColor_oriimg/cate' sprintf( '%02d', c) '/ori_' num2str(i) '.jpg' ],'file')
            error('img wrong');
        end
        
        if ~exist(['/home/mengmi/Projects/Proj_context2/Datasets/MSCOCO/trainColor_img/cate' sprintf( '%02d', c) '/img_' num2str(i) '.jpg' ],'file')
            error('img wrong');
        end
        
        if ~exist(['/home/mengmi/Projects/Proj_context2/Datasets/MSCOCO/trainColor_binimg/cate' sprintf( '%02d', c) '/bin_' num2str(i) '.jpg' ],'file')
            error('bin wrong');
        end
        
        if ~exist(['/home/mengmi/Projects/Proj_context2/Datasets/MSCOCO/trainColor_crimg/cate' sprintf( '%02d', c) '/crimg_' num2str(i) '.jpg' ],'file')
            error('bin wrong');
        end
        
        fprintf(fileIDori,'%s\n',['cate' sprintf( '%02d', c) '/ori_' num2str(i) '.jpg' ]);
        fprintf(fileIDimg,'%s\n',['cate' sprintf( '%02d', c) '/img_' num2str(i) '.jpg' ]);
        fprintf(fileIDbinimg,'%s\n',['cate' sprintf( '%02d', c) '/bin_' num2str(i) '.jpg' ]);
        fprintf(fileIDcrimg,'%s\n',['cate' sprintf( '%02d', c) '/crimg_' num2str(i) '.jpg' ]);
%         fprintf(fileIDcrimg,'%s\n',['cate' num2str(c) '/' imglist_crimg(i).name ]);
%         fprintf(fileIDcateg,'%s\n',['cate' num2str(c) '/' imglist_categ(i).name]);
        fprintf(fileIDlabels, '%s\n', num2str(c));
    end
end
fclose(fileIDori);
fclose(fileIDimg);
% fclose(fileIDcateg);
fclose(fileIDlabels);
fclose(fileIDbinimg);
fclose(fileIDcrimg);
