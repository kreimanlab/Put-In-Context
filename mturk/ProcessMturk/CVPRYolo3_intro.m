clear all; close all; clc;

load(['/home/mengmi/Desktop/PyTorch-YOLOv3/results_fig1intro/img_4_18_9_2622.mat']);
imgsize = 416;
gray = zeros(imgsize,imgsize);
detections = ceil(detections);
detections1 = detections(:,1:4);
detections1(detections1<1) = 1;
detections1(detections1>imgsize) = imgsize;

for i = 1:size(detections,1)
    gray(detections1(i,2):detections1(i,4),detections1(i,1):detections1(i,3)) = detections(i,7)+1;
end
problabel = gray;