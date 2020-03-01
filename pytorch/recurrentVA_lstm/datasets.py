from torch.utils.data import Dataset
import os
from scipy.misc import imread, imresize
import numpy as np
import cv2

class DualLoadDatasets(Dataset):
    """
    A PyTorch Dataset class to be used in a PyTorch DataLoader to create batches.
    """

    def __init__(self, imgsize, txt_folder, img_folder, crimg_folder, bin_folder, split, Gfiltersz, Gblursigma, transform=None):
        """
        :param data_folder: folder where data files are stored
        :param data_name: base name of processed datasets
        :param split: split, one of 'TRAIN', 'VAL', or 'TEST'
        :param transform: image transform pipeline
        :param Gfiltersz: image gaussian blur filter size
        :param Gblursigma: image gaussian blur variance
        """
        self.split = split
        self.imgsize = imgsize
        self.Gfiltersz = Gfiltersz
        self.Gblursigma = Gblursigma
        self.imgfolder = img_folder
        
        assert self.split in {'train', 'val', 'test','testhuman','testRprior','test_expA_','test_expB_','test_expC_','test_expD_','test_expE_','test_expG_','test_expH_'}

        with open(os.path.join(txt_folder, self.split + 'Color_oriimg.txt'),'rb') as f:
            self.imglist = [os.path.join(img_folder, line.strip()) for line in f]
            #self.imglist = ['data/samples/person.jpg' for line in f]
        
        if self.split != 'train' and self.split != 'val':
            
            if self.split == 'test_expD_':
                with open(os.path.join(txt_folder, self.split + 'Color_oriimg.txt'),'rb') as f:
                    self.crimglist = [os.path.join(crimg_folder,line.strip()[:-8]+'crimg.jpg') for line in f]
                    #print(self.crimglist[0])
            else:
                with open(os.path.join(txt_folder, self.split + 'Color_binimg.txt'),'rb') as f:
                    self.crimglist = [os.path.join(crimg_folder,line.strip()[:-15]+'crimg.jpg') for line in f]
                    #print(self.crimglist[0])        
        else:
            with open(os.path.join(txt_folder, self.split + 'Color_crimg.txt'),'rb') as f:
                self.crimglist = [os.path.join(crimg_folder, line.strip()) for line in f]
                
            
        with open(os.path.join(txt_folder, self.split + 'Color_binimg.txt'),'rb') as f:
            self.binlist = [os.path.join(bin_folder,line.strip()) for line in f]
             
        with open(os.path.join(txt_folder, self.split + 'Color_label.txt'),'rb') as f:
            self.labellist = [int(line) for line in f]


        # PyTorch transformation pipeline for the image (normalizing, etc.)
        self.transform = transform

        # Total number of datapoints
        self.dataset_size = len(self.imglist)

    def __getitem__(self, i):
                
        # Read images
        #print(self.imglist[i])
        #print(self.binlist[i])
        #print(self.labellist[i])
        img = imread(self.imglist[i])
        
        if len(img.shape) == 2:
            img = img[:, :, np.newaxis]
            img = np.concatenate([img, img, img], axis=2)
        img = imresize(img, (self.imgsize, self.imgsize))           
        assert np.max(img) <= 255       
        
        if self.transform is not None:
            img = self.transform(img) 
            
        # Read binimg
        binimg = imread(self.binlist[i],'L')
        binimg = imresize(binimg, (self.imgsize, self.imgsize))
                    
        # read cropped image    
        crimg = imread(self.crimglist[i])
        
        if len(crimg.shape) == 2:
            crimg = crimg[:, :, np.newaxis]
            crimg = np.concatenate([crimg, crimg, crimg], axis=2)
        crimg = imresize(crimg, (self.imgsize, self.imgsize))           
        assert np.max(crimg) <= 255       
        
        if self.transform is not None:
            crimg = self.transform(crimg) 
            
        blur = cv2.GaussianBlur(img,(self.Gfiltersz,self.Gfiltersz),self.Gblursigma,self.Gblursigma,-1)
                   
        label = self.labellist[i]
    
        #transpose images
        #img = img.transpose(2, 0, 1)
        #assert img.shape == (3, self.imgsize, self.imgsize)     
        if self.split != 'train' and self.split != 'val':
            
            if self.split == 'test_expG_':
                binimgtemp = np.expand_dims(binimg,axis=2).repeat(3,2).copy() 
                imgobj = img.copy()
                imgcontext = img.copy()
                imgobj[np.where(binimgtemp == 0)] = binimgtemp[np.where(binimgtemp == 0)]
                imgcontext[np.where(binimgtemp == 255)] = binimgtemp[np.where(binimgtemp == 255)]*0                
                return img, binimg, blur, label, self.imglist[i], imgobj, imgcontext, crimg
            
            elif self.split == 'test_expB_':
                
                porscillaname = '/home/mengmi/Projects/Proj_context2/Matlab/Stimulus/keyframe_expB/' + self.imglist[i][len(self.imgfolder):-22] + '_PortillaMask.jpg'
                #print(porscillaname)
                Pmask = imread(porscillaname)
        
                if len(Pmask.shape) == 2:
                    Pmask = Pmask[:, :, np.newaxis]
                    Pmask = np.concatenate([Pmask, Pmask, Pmask], axis=2)
                    
                Pmask = imresize(Pmask, (self.imgsize, self.imgsize))  
                return img, binimg, blur, label, self.imglist[i], Pmask, crimg
            else:
                return img, binimg, blur, label, self.imglist[i], crimg
        else:
            return img, binimg, blur, label, crimg
        

    def __len__(self):
        return self.dataset_size
