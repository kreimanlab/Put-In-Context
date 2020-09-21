#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Aug 22 13:34:34 2019

@author: mengmi
"""


import torch
import cv2
import numpy as np


def preprocessBatch(imgs, transform, batchsz, device):
    #img size: (batchsize, imgsize, imgsize, channels)
    
    #for tensor
    #imgs = imgs.transpose(1,3)
    #imgs = imgs.transpose(2,3)
    
    #for numpy array
    imgs = imgs.transpose((0,3,1,2)) 
    imgs = torch.FloatTensor(imgs / 255.)
    imgL = []
    for i in range(batchsz):
        img = imgs[i,:,:,:]        
        img = transform(img)
        imgL.append(img)
     
    imgs = torch.stack(imgL) #generate batch of images
    imgs = imgs.to(device)
    return imgs
    
def fcn_clicking(batch_size, img_size, imgL, maskL, blurL, binL, xh, yv, clickR):
    assert len(xh) == batch_size
    assert len(yv) == batch_size
    assert imgL.shape == (batch_size, img_size, img_size, 3)
    assert blurL.shape == (batch_size, img_size, img_size, 3)
    assert maskL.shape == (batch_size, img_size, img_size)
    assert binL.shape == (batch_size, img_size, img_size)
    
    clickL = blurL.copy()
    
    for i in range(0,batch_size):
        img = imgL[i,:,:,:]
        mask = maskL[i,:,:]
        binimg = binL[i,:,:]        
        click = clickL[i,:,:,:]
        
        #make sure mouse click within image range
#        if xh[i]<1: xh[i]=1
#        if yv[i]<1: yv[i]=1
#        if xh[i]>img_size: xh[i]=img_size
#        if yv[i]>img_size: yv[i]=img_size
        
        mask = cv2.circle(mask, (xh[i],yv[i]),clickR,(255),-1)
        click[np.where(mask == 255)] = img[np.where(mask == 255)]
        click[np.where(binimg == 255)] = img[np.where(binimg == 255)]
        clickL[i,:,:,:] = click
    
    return maskL, clickL

def fcn_findMaxLocAlphaMap(batch_size, img_size, alphas): 
    xh = []
    yv = []
    for i in range(0,batch_size):
        binimg = alphas[i,:,:]
        binimg = cv2.resize(binimg,(img_size, img_size))
        assert binimg.shape == (img_size, img_size)
        (minVal, maxVal, minLoc, maxLoc) = cv2.minMaxLoc(binimg)
        #print(maxLoc)
        xh.append(maxLoc[0])
        yv.append(maxLoc[1])

    return xh, yv