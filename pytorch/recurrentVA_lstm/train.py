import time
import torch.backends.cudnn as cudnn
import torch.optim
import torch.utils.data
from torch import nn
#from torch.nn.utils.rnn import pack_padded_sequence
from models import Encoder, DecoderWithAttention
from datasets import DualLoadDatasets
from utils import save_checkpoint, AverageMeter, clip_gradient, accuracy
from torchvision import transforms


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

# Data parameters
imgsz = 400 #image size
Gblursigma = 64 #gaussian filter variance
Gfiltersz = 51 #gaussian filter size
ClickRadius = 55 #click radius
txt_folder = '/home/mengmi/Projects/Proj_context2/Datalist/' 
crimg_folder = '/home/mengmi/Projects/Proj_context2/Datasets/MSCOCO/trainColor_crimg/'
img_folder = '/home/mengmi/Projects/Proj_context2/Datasets/MSCOCO/trainColor_oriimg/'
bin_folder = '/home/mengmi/Projects/Proj_context2/Datasets/MSCOCO/trainColor_binimg/'
split = 'train'

# Model parameters
emb_dim = 55  # dimension of word embeddings; not being used
attention_dim = 512  # dimension of attention linear layers
decoder_dim = 512  # dimension of decoder RNN
vocab_size = 55 # number of output object categories
encoder_dim = 512 #the layer after 4th block in resnet: default 2048
dropout = 0.5
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")  # sets device for model and PyTorch tensors
cudnn.benchmark = True  # set to true only if inputs to model are fixed size; otherwise lot of computational overhead

# Training parameters
start_epoch = 0
epochs = 5  # number of epochs to train for (if early stopping is not triggered)
batch_size = 24
click_steps = 9
decode_lengths = torch.ones(batch_size)*click_steps #constant number of mouse clicks
workers = 1  # for data-loading; right now, only 1 works with h5py
encoder_lr = 1e-4  # learning rate for encoder if fine-tuning
decoder_lr = 4e-4  # learning rate for decoder
grad_clip = 5.  # clip gradients at an absolute value of
alpha_c = 3.  # regularization parameter for 'doubly stochastic attention', as in the paper; default: 1.0
print_freq = 1  # print training/validation stats every __ batches
fine_tune_encoder = True  # fine-tune encoder?
checkpoint = None  # path to checkpoint, None if none

transform = image_transforms['train']

def main():
    """
    Training and validation.
    """

    global checkpoint, start_epoch, fine_tune_encoder

    # Initialize / load checkpoint
    if checkpoint is None:
        
        encoder = Encoder()
        print(encoder)
        encoder.fine_tune(fine_tune_encoder)
        encoder_optimizer = torch.optim.Adam(params=filter(lambda p: p.requires_grad, encoder.parameters()),
                                             lr=encoder_lr) if fine_tune_encoder else None
                                      
        decoder = DecoderWithAttention(attention_dim=attention_dim,
                                       embed_dim=emb_dim,
                                       decoder_dim=decoder_dim,
                                       vocab_size = vocab_size,
                                       encoder_dim = encoder_dim,
                                       dropout=dropout)
        decoder_optimizer = torch.optim.Adam(params=filter(lambda p: p.requires_grad, decoder.parameters()),
                                             lr=decoder_lr)
        

    else:
        checkpoint = torch.load(checkpoint)
        start_epoch = checkpoint['epoch'] + 1           
        decoder = checkpoint['decoder']
        decoder_optimizer = checkpoint['decoder_optimizer']
        encoder = checkpoint['encoder']
        encoder_optimizer = checkpoint['encoder_optimizer']
        if fine_tune_encoder is True and encoder_optimizer is None:
            encoder.fine_tune(fine_tune_encoder)
            encoder_optimizer = torch.optim.Adam(params=filter(lambda p: p.requires_grad, encoder.parameters()),
                                                 lr=encoder_lr)

    # Move to GPU, if available
    decoder = decoder.to(device)
    encoder = encoder.to(device)

    # Loss function
    criterion = nn.CrossEntropyLoss().to(device)

    # customized dataloader
    MyDataset = DualLoadDatasets(imgsz, txt_folder, img_folder, crimg_folder, bin_folder,split, Gfiltersz, Gblursigma)
    #drop the last batch since it is not divisible by batchsize
    train_loader = torch.utils.data.DataLoader(MyDataset, batch_size=batch_size, shuffle=True, num_workers=workers, pin_memory=True, drop_last = True) 
    
#    val_loader = torch.utils.data.DataLoader(
#        CaptionDataset(data_folder, data_name, 'VAL', transform=transforms.Compose([normalize])),
#        batch_size=batch_size, shuffle=True, num_workers=workers, pin_memory=True)
    
    # Save checkpoint
    epoch = 0
    save_checkpoint(epoch, encoder, decoder, encoder_optimizer,
                    decoder_optimizer)
    print('saving models to models/checkpoint')

    # Epochs
    for epoch in range(start_epoch, epochs):
        #print(image_transforms)
                
        # One epoch's training
        train(train_loader=train_loader,
              encoder=encoder,
              decoder=decoder,
              transform = transform,
              criterion=criterion,
              encoder_optimizer=encoder_optimizer,
              decoder_optimizer=decoder_optimizer,
              epoch=epoch)

        # Save checkpoint
        save_checkpoint(epoch, encoder, decoder, encoder_optimizer,
                        decoder_optimizer)
        print('saving models to models/checkpoint')

def train(train_loader, encoder, decoder, transform, criterion, encoder_optimizer, decoder_optimizer, epoch):
    """
    Performs one epoch's training.

    :param train_loader: DataLoader for training data
    :param encoder: encoder model
    :param decoder: decoder model
    :param criterion: loss layer
    :param encoder_optimizer: optimizer to update encoder's weights (if fine-tuning)
    :param decoder_optimizer: optimizer to update decoder's weights
    :param epoch: epoch number
    """

    decoder.train()  # train mode (dropout and batchnorm is used)
    encoder.train()

    batch_time = AverageMeter()  # forward prop. + back prop. time
    data_time = AverageMeter()  # data loading time
    losses = AverageMeter()  # loss (per word decoded)
    top5accs = AverageMeter()  # top5 accuracy

    start = time.time()

    # Batches
    for i, (imgs, binimgs, blurs, labels, crimg) in enumerate(train_loader):
        #print (i)
        
        data_time.update(time.time() - start)
        #labels are always within range [0,numclass-1]
        labels = labels.long() - 1
        #print(labels.shape)
        
        #generate one-hot vector embeddings for each batch image based on class labels
        #embeddings = torch.zeros(batch_size, vocab_size).scatter_(1, labels.unsqueeze(1), 1.).to(device)
                
        # forward everything
        scores, alphas_obj, alphas_context, acc_alphas_obj, acc_alphas_context,  _ = decoder(encoder, transform, imgs, blurs, binimgs, click_steps, batch_size, imgsz, ClickRadius, crimg)
        #print('scores')
        #print(scores)
        #print('alphas')
        #print(alphas.shape)

        # a tensor of dimension, [batchsize, mouseclick steps, 1] where each entry refers to a target label choosing from [1,80]
        targets = labels.to(device).unsqueeze(1).repeat(1,click_steps).view(-1)
        scores = scores.view(-1,vocab_size)
        #scores_obj = scores_obj.view(-1,vocab_size)
        #scores_context = scores_context.view(-1,vocab_size)
        #print('targets')
        #print(targets.shape)
        #print('scores')
        #print(scores.shape)

        # Remove timesteps that we didn't decode at, or are pads
        # pack_padded_sequence is an easy trick to do this
        #scores = pack_padded_sequence(scores, decode_lengths.cpu().numpy(), batch_first=True)
        #targets = pack_padded_sequence(targets, decode_lengths.cpu().numpy(), batch_first=True)

        # Calculate loss
        loss = criterion(scores, targets)
        #loss = loss + 0.5*criterion(scores_obj, targets) + 0.5*criterion(scores_context, targets)
        #scores = scores.view(batch_size,click_steps ,vocab_size)
        #targets = targets.view(batch_size, click_steps)
        #spread = ((1. - alphas.sum(dim=1)) ** 2).mean()
        #print('spread')
        #print(spread)
        
        # Add doubly stochastic attention regularization
        #loss = loss + alpha_c * ((1. - alphas_obj.sum(dim=1)) ** 2).mean() + alpha_c * ((1. - alphas_context.sum(dim=1)) ** 2).mean()

        # Back prop.
        decoder_optimizer.zero_grad()
        if encoder_optimizer is not None:
            encoder_optimizer.zero_grad()
        loss.backward()

        #Clip gradients
        if grad_clip is not None:
            clip_gradient(decoder_optimizer, grad_clip)
            if encoder_optimizer is not None:
                clip_gradient(encoder_optimizer, grad_clip)

        # Update weights
        decoder_optimizer.step()
        if encoder_optimizer is not None:
            encoder_optimizer.step()

        #Keep track of metrics
        top5 = accuracy(scores, targets, 1) #top-1 accuracy
        losses.update(loss.item(), sum(decode_lengths))
        top5accs.update(top5, sum(decode_lengths))
        batch_time.update(time.time() - start)

        start = time.time()

        # Print status
        if i % print_freq == 0:
            print('Epoch: [{0}][{1}/{2}]\t'
                  'Batch Time {batch_time.val:.3f} ({batch_time.avg:.3f})\t'
                  'Data Load Time {data_time.val:.3f} ({data_time.avg:.3f})\t'
                  'Loss {loss.val:.4f} ({loss.avg:.4f})\t'
                  'Top-1 Accuracy {top5.val:.3f} ({top5.avg:.3f})'.format(epoch, i, len(train_loader),
                                                                          batch_time=batch_time,
                                                                          data_time=data_time, loss=losses,
                                                                          top5=top5accs))



if __name__ == '__main__':
    main()
