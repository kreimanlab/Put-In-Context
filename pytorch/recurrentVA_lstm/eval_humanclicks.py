#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Aug 24 13:30:20 2019

@author: mengmi
"""
import torch.utils.data
from datasets import DualLoadDatasets
import torch.backends.cudnn as cudnn
import torch.optim
import torch.utils.data
import torchvision.transforms as transforms
from utils import AverageMeter, accuracy, visualize_att
import os
import scipy.io as sio
import numpy as np
# Parameters

# Data parameters
imgsz = 400 #image size
Gblursigma = 64 #gaussian filter variance
Gfiltersz = 51 #gaussian filter size
ClickRadius = 55 #click radius
txt_folder = '/home/mengmi/Projects/Proj_context1/Datalist/' 
img_folder = '/home/mengmi/Projects/Proj_context1/Datasets/MSCOCO/mouseclick/'
bin_folder = '/home/mengmi/Projects/Proj_context1/Datasets/MSCOCO/testColor_binimg/'
split = 'testhuman'

batch_size = 1
click_steps = 9
workers = 1
decode_lengths = torch.ones(batch_size)*click_steps #constant number of mouse clicks

checkpoint = 'models/checkpoint_2.pth.tar'  # model checkpoint
word_map_file = '/home/mengmi/Projects/Proj_context1/Datalist/ClassLabelList.txt'  # word map, ensure it's the same the data was encoded with and the model was trained with
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")  # sets device for model and PyTorch tensors
cudnn.benchmark = True  # set to true only if inputs to model are fixed size; otherwise lot of computational overhead

# Load model
checkpoint = torch.load(checkpoint)
decoder = checkpoint['decoder']
decoder = decoder.to(device)
decoder.eval()
encoder = checkpoint['encoder']
encoder = encoder.to(device)
encoder.eval()

# Load word map (word2ix)
with open(word_map_file,'rb') as f:
    classlabellist = [line.strip() for line in f]
vocab_size = len(classlabellist)

# customized dataloader
MyDataset = DualLoadDatasets(imgsz, txt_folder, img_folder, bin_folder,split, Gfiltersz, Gblursigma)
#drop the last batch since it is not divisible by batchsize
test_loader = torch.utils.data.DataLoader(MyDataset, batch_size=batch_size, shuffle=False, num_workers=workers, pin_memory=True, drop_last = False) 

# Normalization transform
# Applying Transforms to the Data
image_transforms = { 
    'train': transforms.Compose([
        transforms.ToPILImage(),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406],
                                     std=[0.229, 0.224, 0.225])
    ]),
    'valid': transforms.Compose([ 
        transforms.ToPILImage(),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406],
                             [0.229, 0.224, 0.225])
    ]),
    'test': transforms.Compose([
        transforms.ToPILImage(),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406],
                             [0.229, 0.224, 0.225])
    ])
}
    
    
transform = image_transforms['train']


def evaluate():
    """
    Evaluation

    :param beam_size: beam size at which to generate captions for evaluation
    :return: BLEU-4 score
    """
    top5accs = AverageMeter()  # top5 accuracy
    
    # For each image
    for i, (imgs, binimgs, blurs, labels, imgname) in enumerate(test_loader):
        
        #labels are always within range [0,numclass-1]
        labels = labels.long() - 1
#        print(labels)
#        print(imgname)
        
        # forward everything
        scores, alphas, clickS = decoder.forward_HumanClicks(encoder, transform, imgs, blurs, binimgs, click_steps, batch_size, imgsz, ClickRadius)
#        print('scores')
#        print(scores.shape)
        #print('alphas')
        #print(alphas.shape)

        # a tensor of dimension, [batchsize, mouseclick steps, 1] where each entry refers to a target label choosing from [1,80]
        targets = labels.to(device).unsqueeze(1).repeat(1,click_steps).view(-1)
        scores = scores.view(-1,vocab_size)
        top5 = accuracy(scores, targets, 5)
        top5accs.update(top5, sum(decode_lengths))
        
        _, predicted_seq = scores.topk(1, 1, True, True) #get top 1 predictions
        predicted_seq = predicted_seq.detach().cpu()
        
        #visualize attention map and predicted class labels
        #img_path = os.path.join(img_folder, 'trial_' + str(i+1) + '.jpg')
        alphas = alphas[0].detach().cpu()
        #visualize_att(img_path, predicted_seq, alphas, classlabellist, smooth=True)
#        print('===============')
#        print(imgname[0][len(img_folder):-4])
        #save results
        sio.savemat('results_humanclick/'+ imgname[0][len(img_folder):-4] + '.mat', {'predicted_seq':np.asarray(predicted_seq, dtype=np.int32), 'alphas': alphas.numpy(), 'clickS':clickS})
        print('Iter: [{0}/{1}]\t'
              'Top-5 Accuracy {top5.val:.3f} ({top5.avg:.3f})'.format(i, len(test_loader), top5=top5accs))


if __name__ == '__main__':
    
    evaluate()