import torch
from torch import nn
import torchvision
import numpy as np
from preprocess import preprocessBatch, fcn_clicking, fcn_findMaxLocAlphaMap

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")


class Encoder(nn.Module):
    """
    Encoder.
    """

    def __init__(self, encoded_image_size=28):
        super(Encoder, self).__init__()
        self.enc_image_size = encoded_image_size

        resnet = torchvision.models.vgg16(pretrained=True)  # pretrained ImageNet ResNet-101

        # Remove linear and pool layers (since we're not doing classification)
        #modules = list(resnet.children())[:-2]
        #self.resnet = nn.Sequential(*modules)
        self.resnet = resnet.features
        
        # Resize image to fixed size to allow input images of variable size
        self.adaptive_pool = nn.AdaptiveAvgPool2d((encoded_image_size, encoded_image_size))

        self.fine_tune()

    def forward(self, images):
        """
        Forward propagation.

        :param images: images, a tensor of dimensions (batch_size, 3, image_size, image_size)
        :return: encoded images
        """
        out = self.resnet(images)  # (batch_size, 2048, image_size/32, image_size/32)
        out = self.adaptive_pool(out)  # (batch_size, 2048, encoded_image_size, encoded_image_size)
        #print('out')
        #print(out.shape)
        out = out.permute(0, 2, 3, 1)  # (batch_size, encoded_image_size, encoded_image_size, 2048)
        return out

    def fine_tune(self, fine_tune=True):
        """
        Allow or prevent the computation of gradients for convolutional blocks 2 through 4 of the encoder.

        :param fine_tune: Allow?
        """
        for p in self.resnet.parameters():
            p.requires_grad = False
        # If fine-tuning, only fine-tune convolutional blocks 2 through 4
        for c in list(self.resnet.children())[24:]:
            for p in c.parameters():
                p.requires_grad = fine_tune


class Attention(nn.Module):
    """
    Attention Network.
    """

    def __init__(self, encoder_dim, decoder_dim, attention_dim):
        """
        :param encoder_dim: feature size of encoded images
        :param decoder_dim: size of decoder's RNN
        :param attention_dim: size of the attention network
        """
        super(Attention, self).__init__()
        self.encoder_att_obj = nn.Linear(encoder_dim, attention_dim)  # linear layer to transform encoded image
        self.encoder_att_context = nn.Linear(encoder_dim, attention_dim)  # linear layer to transform encoded image
        
        self.decoder_att = nn.Linear(decoder_dim, attention_dim)  # linear layer to transform decoder's output
        
        
        self.full_att_obj = nn.Linear(attention_dim, 1)  # linear layer to calculate values to be softmax-ed
        self.full_att_context = nn.Linear(attention_dim, 1)  # linear layer to calculate values to be softmax-ed
        
        self.relu = nn.ReLU()
        self.softmax = nn.Softmax(dim=1)  # softmax layer to calculate weights

    def forward(self, encoder_out_obj, encoder_out_context, decoder_hidden):
        """
        Forward propagation.

        :param encoder_out: encoded images, a tensor of dimension (batch_size, num_pixels, encoder_dim)
        :param decoder_hidden: previous decoder output, a tensor of dimension (batch_size, decoder_dim)
        :return: attention weighted encoding, weights
        """
        att1_obj = self.encoder_att_obj(encoder_out_obj)  # (batch_size, num_pixels, attention_dim)
        att1_context = self.encoder_att_context(encoder_out_context)  # (batch_size, num_pixels, attention_dim)
        
        att2 = self.decoder_att(decoder_hidden)  # (batch_size, attention_dim)
        
        att_obj = self.full_att_obj(self.relu(att1_obj + att2.unsqueeze(1))).squeeze(2)  # (batch_size, num_pixels)
        alpha_obj = self.softmax(att_obj)  # (batch_size, num_pixels)
        attention_weighted_encoding_obj = (encoder_out_obj * alpha_obj.unsqueeze(2)).sum(dim=1)  # (batch_size, encoder_dim)
        
        att_context = self.full_att_context(self.relu(att1_context + att2.unsqueeze(1))).squeeze(2)  # (batch_size, num_pixels)
        alpha_context = self.softmax(att_context)  # (batch_size, num_pixels)
        attention_weighted_encoding_context = (encoder_out_context * alpha_context.unsqueeze(2)).sum(dim=1)  # (batch_size, encoder_dim)

        #attention_weighted_encoding = torch.attention_weighted_encoding_obj + attention_weighted_encoding_context
        attention_weighted_encoding = torch.cat((attention_weighted_encoding_obj, attention_weighted_encoding_context), 1)
        return attention_weighted_encoding, alpha_obj, alpha_context


class DecoderWithAttention(nn.Module):
    """
    Decoder.
    """

    def __init__(self, attention_dim, embed_dim, decoder_dim, vocab_size, encoder_dim=2048, dropout=0.5):
        """
        :param attention_dim: size of attention network
        :param embed_dim: embedding size
        :param decoder_dim: size of decoder's RNN
        :param vocab_size: size of vocabulary
        :param encoder_dim: feature size of encoded images
        :param dropout: dropout
        """
        super(DecoderWithAttention, self).__init__()

        self.encoder_dim = encoder_dim
        self.attention_dim = attention_dim
        self.embed_dim = embed_dim
        self.decoder_dim = decoder_dim
        self.vocab_size = vocab_size
        self.dropout = dropout
        
        self.attention = Attention(encoder_dim, decoder_dim, attention_dim)  # attention network; # (batch_size, encoder_dim)

        #self.embedding = nn.Embedding(vocab_size, embed_dim)  # embedding layer
        self.dropout = nn.Dropout(p=self.dropout)
        self.decode_step = nn.LSTMCell(encoder_dim*2, decoder_dim, bias=True)  # decoding LSTMCell
        self.init_h = nn.Linear(encoder_dim, decoder_dim)  # linear layer to find initial hidden state of LSTMCell
        self.init_c = nn.Linear(encoder_dim, decoder_dim)  # linear layer to find initial cell state of LSTMCell
        self.f_beta = nn.Linear(decoder_dim, encoder_dim*2)  # linear layer to create a sigmoid-activated gate
        self.sigmoid = nn.Sigmoid()
        self.fc = nn.Linear(decoder_dim, vocab_size)  # linear layer to find scores over vocabulary
        self.init_weights()  # initialize some layers with the uniform distribution

    def init_weights(self):
        """
        Initializes some parameters with values from the uniform distribution, for easier convergence.
        """
        #self.embedding.weight.data.uniform_(-0.1, 0.1)
        self.fc.bias.data.fill_(0)
        self.fc.weight.data.uniform_(-0.1, 0.1)

    def init_hidden_state(self, encoder_out):
        """
        Creates the initial hidden and cell states for the decoder's LSTM based on the encoded images.

        :param encoder_out: encoded images, a tensor of dimension (batch_size, num_pixels, encoder_dim)
        :return: hidden state, cell state
        """
        mean_encoder_out = encoder_out.mean(dim=1)
        h = self.init_h(mean_encoder_out)  # (batch_size, decoder_dim)
        c = self.init_c(mean_encoder_out)
        return h, c

    def forward(self, encoder, transform, imgL, blurL, binL, time_steps, batch_size, img_size, ClickRadius, crimg):
        """
        Forward propagation.
        :param embeddings: encoded labels, in one-hot vectors ((batch_size, max_caption_length, embed_dim) where 1 is classlabel, the rest are 0)
        :param imgL: images, a tensor of dimension (batch_size, imgsz, imgsz, 3)
        :param imgL: images, a tensor of dimension (batch_size, imgsz, imgsz, 3)
        :param imgL: images, a tensor of dimension (batch_size, imgsz, imgsz, 3)
        :param imgL: images, a tensor of dimension (batch_size, imgsz, imgsz, 3)
        :param encoded_labels: encoded captions, a tensor of dimension (batch_size, max_caption_length)
        :param caption_lengths: constant caption length (scalar: always fixed)
        :return: scores for vocabulary, sorted encoded captions, decode lengths, weights, sort indices
        """
        #pre-process: convert all tensors to numpy arrays
        imgL = imgL.numpy()
        blurL = blurL.numpy()
        binL = binL.numpy()
        crimg= crimg.numpy()
        
        
        #make binL 3 channels and ready for encoder        
        inputs = np.expand_dims(binL,axis=3).repeat(3,3).copy()        
        inputs = preprocessBatch(inputs, transform, batch_size, device) #(batchsize, channels = 3, imgsize, imgsize)
        
        # Forward prop. to get init_h and init_c
        encoder_out_init = encoder(inputs)

        batch_size = encoder_out_init.size(0)
        encoder_dim = encoder_out_init.size(-1)
        alpha_size = encoder_out_init.size(1)
        vocab_size = self.vocab_size

        # Flatten image
        encoder_out_init = encoder_out_init.view(batch_size, -1, encoder_dim)  # (batch_size, num_pixels, encoder_dim)
        num_pixels = encoder_out_init.size(1)

        # Initialize LSTM state
        h, c = self.init_hidden_state(encoder_out_init)  # (batch_size, decoder_dim)        
        #print(h.shape)
        #print(c.shape)
        # Create tensors to hold word predicion scores and alphas and masks (storing mouse clicking locations)
        predictions = torch.zeros(batch_size, time_steps, vocab_size).to(device)
        alphas_obj = torch.zeros(batch_size, time_steps, num_pixels).to(device)
        alphas_context = torch.zeros(batch_size, time_steps, num_pixels).to(device)
        
        alpha_obj = torch.zeros(batch_size, alpha_size, alpha_size).to(device)
        alpha_context = torch.zeros(batch_size, alpha_size, alpha_size).to(device)
        
        #maskL = np.zeros((batch_size, img_size, img_size))
        clickS = np.zeros((batch_size, time_steps, img_size, img_size, 3))
        # At each time-step, decode by
        # attention-weighing the encoder's output based on the decoder's previous hidden state output
        # then generate a new word in the decoder with the previous word and the attention weighted encoding
        for t in range(time_steps):
            
            if t == 0: #the first time step
                #clickS[:,t,:] = imgL.copy()
                #clickS[:,t,:] = blurL.copy()
                inputs_obj = crimg.copy()
#                inputs = imgL.copy()
                inputs_obj = preprocessBatch(inputs_obj, transform, batch_size, device)
                inputs_obj = encoder(inputs_obj)
                
                inputs_context = imgL.copy()
#                inputs = imgL.copy()
                inputs_context = preprocessBatch(inputs_context, transform, batch_size, device)
                inputs_context = encoder(inputs_context)
                
            else:
                #alphanorm = alpha.view(batch_size,alpha_size,alpha_size).cpu().clone().detach().numpy()
                #xh, yv = fcn_findMaxLocAlphaMap(batch_size, img_size, alphanorm) 
                #maskL, clickL = fcn_clicking(batch_size, img_size, imgL, maskL, blurL, binL, xh, yv, ClickRadius)
                #clickS[:,t,:] = clickL.copy()
                #inputs = clickL.copy()
                inputs_obj = crimg.copy()
#                inputs = imgL.copy()
                inputs_obj = preprocessBatch(inputs_obj, transform, batch_size, device)
                inputs_obj = encoder(inputs_obj)
                
                inputs_context = imgL.copy()
#                inputs = imgL.copy()
                inputs_context = preprocessBatch(inputs_context, transform, batch_size, device)
                inputs_context = encoder(inputs_context)
            
            # Flatten image
            inputs_obj = inputs_obj.view(batch_size, -1, encoder_dim)
            inputs_context = inputs_context.view(batch_size, -1, encoder_dim)
            #inputs = torch.cat((inputs_obj, inputs_context), 1)  # (batch_size, num_pixels, encoder_dim)
            #print('inputs')
            #print(inputs.shape)
            attention_weighted_encoding, alpha_obj, alpha_context = self.attention(inputs_obj, inputs_context, h)
            #print('attention_weighted_encoding')
            #print(attention_weighted_encoding.shape)
            #print('alpha')
            #print(alpha.shape)
            gate = self.sigmoid(self.f_beta(h))  # gating scalar, (batch_size_t, encoder_dim)
            attention_weighted_encoding = gate * attention_weighted_encoding
            #h, c = self.decode_step(torch.cat([embeddings, attention_weighted_encoding], dim=1), (h, c))  # (batch_size_t, decoder_dim)
            h, c = self.decode_step(attention_weighted_encoding, (h, c))  # (batch_size_t, decoder_dim)
            preds = self.fc(self.dropout(h))  # (batch_size_t, vocab_size)
            predictions[:, t, :] = preds
            alphas_context[:, t, :] = alpha_context
            alphas_obj[:, t, :] = alpha_obj

        return predictions, alphas_obj, alphas_context, clickS
    
    def forwardExpB(self, encoder, transform, imgL, blurL, binL, time_steps, batch_size, img_size, ClickRadius, Pmask, TSC, crimg):
        #pre-process: convert all tensors to numpy arrays
        imgL = imgL.numpy()
        blurL = blurL.numpy()
        binL = binL.numpy()
        Pmask = Pmask.numpy()
        crimg= crimg.numpy()
        
        #make binL 3 channels and ready for encoder        
        inputs = np.expand_dims(binL,axis=3).repeat(3,3).copy()        
        inputs = preprocessBatch(inputs, transform, batch_size, device) #(batchsize, channels = 3, imgsize, imgsize)
        
        # Forward prop. to get init_h and init_c
        encoder_out_init = encoder(inputs)

        batch_size = encoder_out_init.size(0)
        encoder_dim = encoder_out_init.size(-1)
        alpha_size = encoder_out_init.size(1)
        vocab_size = self.vocab_size

        # Flatten image
        encoder_out_init = encoder_out_init.view(batch_size, -1, encoder_dim)  # (batch_size, num_pixels, encoder_dim)
        num_pixels = encoder_out_init.size(1)

        # Initialize LSTM state
        h, c = self.init_hidden_state(encoder_out_init)  # (batch_size, decoder_dim)        
        #print(h.shape)
        #print(c.shape)
        # Create tensors to hold word predicion scores and alphas and masks (storing mouse clicking locations)
        predictions = torch.zeros(batch_size, time_steps, vocab_size).to(device)
        alphas_obj = torch.zeros(batch_size, time_steps, num_pixels).to(device)
        alphas_context = torch.zeros(batch_size, time_steps, num_pixels).to(device)
        #
        alpha_obj = torch.zeros(batch_size, alpha_size, alpha_size).to(device)
        alpha_context = torch.zeros(batch_size, alpha_size, alpha_size).to(device)
        #maskL = np.zeros((batch_size, img_size, img_size))
        clickS = np.zeros((batch_size, time_steps, img_size, img_size, 3))
        # At each time-step, decode by
        # attention-weighing the encoder's output based on the decoder's previous hidden state output
        # then generate a new word in the decoder with the previous word and the attention weighted encoding
        for t in range(time_steps):
            
            if t >= TSC: #the first time step
                #clickS[:,t,:] = imgL.copy()
                #clickS[:,t,:] = blurL.copy()
                inputs_obj = np.zeros(crimg.shape)
                #print(inputs_obj.shape)
#                inputs = imgL.copy()
                inputs_obj = preprocessBatch(inputs_obj, transform, batch_size, device)
                inputs_obj = encoder(inputs_obj)
                
                inputs_context = Pmask.copy()
#                inputs = imgL.copy()
                inputs_context = preprocessBatch(inputs_context, transform, batch_size, device)
                inputs_context = encoder(inputs_context)
                
            else:
                #alphanorm = alpha.view(batch_size,alpha_size,alpha_size).cpu().clone().detach().numpy()
                #xh, yv = fcn_findMaxLocAlphaMap(batch_size, img_size, alphanorm) 
                #maskL, clickL = fcn_clicking(batch_size, img_size, imgL, maskL, blurL, binL, xh, yv, ClickRadius)
                #clickS[:,t,:] = clickL.copy()
                #inputs = clickL.copy()
                inputs_obj = crimg.copy()
#                inputs = imgL.copy()
                inputs_obj = preprocessBatch(inputs_obj, transform, batch_size, device)
                inputs_obj = encoder(inputs_obj)
                
                inputs_context = imgL.copy()
#                inputs = imgL.copy()
                inputs_context = preprocessBatch(inputs_context, transform, batch_size, device)
                inputs_context = encoder(inputs_context)
            
            # Flatten image
            inputs_obj = inputs_obj.view(batch_size, -1, encoder_dim)
            inputs_context = inputs_context.view(batch_size, -1, encoder_dim)
            #inputs = torch.cat((inputs_obj, inputs_context), 1)  # (batch_size, num_pixels, encoder_dim)
            #print('inputs')
            #print(inputs.shape)
            attention_weighted_encoding, alpha_obj, alpha_context = self.attention(inputs_obj, inputs_context, h)
            #print('attention_weighted_encoding')
            #print(attention_weighted_encoding.shape)
            #print('alpha')
            #print(alpha.shape)
            gate = self.sigmoid(self.f_beta(h))  # gating scalar, (batch_size_t, encoder_dim)
            attention_weighted_encoding = gate * attention_weighted_encoding
            #h, c = self.decode_step(torch.cat([embeddings, attention_weighted_encoding], dim=1), (h, c))  # (batch_size_t, decoder_dim)
            h, c = self.decode_step(attention_weighted_encoding, (h, c))  # (batch_size_t, decoder_dim)
            preds = self.fc(self.dropout(h))  # (batch_size_t, vocab_size)
            predictions[:, t, :] = preds
            alphas_context[:, t, :] = alpha_context
            alphas_obj[:, t, :] = alpha_obj

        return predictions, alphas_obj, alphas_context, clickS
    
    def forwardExpG(self, encoder, transform, imgL, blurL, binL, time_steps, batch_size, img_size, ClickRadius, imgobj, imgcontext, TSC, crimg):
        #pre-process: convert all tensors to numpy arrays
        imgL = imgL.numpy()
        blurL = blurL.numpy()
        binL = binL.numpy()
        imgobj = imgobj.numpy()
        imgcontext = imgcontext.numpy()
        crimg= crimg.numpy()
        
        #make binL 3 channels and ready for encoder        
        inputs = np.expand_dims(binL,axis=3).repeat(3,3).copy()        
        inputs = preprocessBatch(inputs, transform, batch_size, device) #(batchsize, channels = 3, imgsize, imgsize)
        
        # Forward prop. to get init_h and init_c
        encoder_out_init = encoder(inputs)

        batch_size = encoder_out_init.size(0)
        encoder_dim = encoder_out_init.size(-1)
        alpha_size = encoder_out_init.size(1)
        vocab_size = self.vocab_size

        # Flatten image
        encoder_out_init = encoder_out_init.view(batch_size, -1, encoder_dim)  # (batch_size, num_pixels, encoder_dim)
        num_pixels = encoder_out_init.size(1)

        # Initialize LSTM state
        h, c = self.init_hidden_state(encoder_out_init)  # (batch_size, decoder_dim)        
        #print(h.shape)
        #print(c.shape)
        # Create tensors to hold word predicion scores and alphas and masks (storing mouse clicking locations)
        predictions = torch.zeros(batch_size, time_steps, vocab_size).to(device)
        alphas_obj = torch.zeros(batch_size, time_steps, num_pixels).to(device)
        alphas_context = torch.zeros(batch_size, time_steps, num_pixels).to(device)
        
        alpha_obj = torch.zeros(batch_size, alpha_size, alpha_size).to(device)
        alpha_context = torch.zeros(batch_size, alpha_size, alpha_size).to(device)
        #maskL = np.zeros((batch_size, img_size, img_size))
        clickS = np.zeros((batch_size, time_steps, img_size, img_size, 3))
        # At each time-step, decode by
        # attention-weighing the encoder's output based on the decoder's previous hidden state output
        # then generate a new word in the decoder with the previous word and the attention weighted encoding
        for t in range(time_steps):
            
            if t >= TSC: #the first time step
                #clickS[:,t,:] = imgL.copy()
                #clickS[:,t,:] = blurL.copy()
                inputs_obj = crimg.copy()
#                inputs = imgL.copy()
                inputs_obj = preprocessBatch(inputs_obj, transform, batch_size, device)
                inputs_obj = encoder(inputs_obj)
                
                inputs_context = imgobj.copy()
#                inputs = imgL.copy()
                inputs_context = preprocessBatch(inputs_context, transform, batch_size, device)
                inputs_context = encoder(inputs_context)
                
            else:
                #alphanorm = alpha.view(batch_size,alpha_size,alpha_size).cpu().clone().detach().numpy()
                #xh, yv = fcn_findMaxLocAlphaMap(batch_size, img_size, alphanorm) 
                #maskL, clickL = fcn_clicking(batch_size, img_size, imgL, maskL, blurL, binL, xh, yv, ClickRadius)
                #clickS[:,t,:] = clickL.copy()
                #inputs = clickL.copy()
                inputs_obj =  np.zeros(crimg.shape)
#                inputs = imgL.copy()
                inputs_obj = preprocessBatch(inputs_obj, transform, batch_size, device)
                inputs_obj = encoder(inputs_obj)
                
                inputs_context = imgcontext.copy()
#                inputs = imgL.copy()
                inputs_context = preprocessBatch(inputs_context, transform, batch_size, device)
                inputs_context = encoder(inputs_context)
            
            # Flatten image
            inputs_obj = inputs_obj.view(batch_size, -1, encoder_dim)
            inputs_context = inputs_context.view(batch_size, -1, encoder_dim)
            #inputs = torch.cat((inputs_obj, inputs_context), 1)  # (batch_size, num_pixels, encoder_dim)
            #print('inputs')
            #print(inputs.shape)
            attention_weighted_encoding, alpha_obj, alpha_context = self.attention(inputs_obj, inputs_context, h)
            #print('attention_weighted_encoding')
            #print(attention_weighted_encoding.shape)
            #print('alpha')
            #print(alpha.shape)
            gate = self.sigmoid(self.f_beta(h))  # gating scalar, (batch_size_t, encoder_dim)
            attention_weighted_encoding = gate * attention_weighted_encoding
            #h, c = self.decode_step(torch.cat([embeddings, attention_weighted_encoding], dim=1), (h, c))  # (batch_size_t, decoder_dim)
            h, c = self.decode_step(attention_weighted_encoding, (h, c))  # (batch_size_t, decoder_dim)
            preds = self.fc(self.dropout(h))  # (batch_size_t, vocab_size)
            predictions[:, t, :] = preds
            alphas_context[:, t, :] = alpha_context
            alphas_obj[:, t, :] = alpha_obj

        return predictions, alphas_obj, alphas_context, clickS

