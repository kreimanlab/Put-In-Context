# Putting Visual Object Recognition in Context

Authors: Mengmi Zhang, Claire Tseng, Gabriel Kreiman

This repository contains an implementation of a recurrent attention deep learning model for recognizing objects in complex backgrounds in natural scenes. Our paper has been accepted in CVPR 2020.

Access to our unofficial manuscript [HERE](https://arxiv.org/abs/1902.00163).

## Project Description

Context plays an important role in visual recognition. Recent studies have shown that visual recognition networks can be fooled by placing objects in inconsistent contexts (e.g. a cow in the ocean). To understand and model the role of contextual information in visual recognition, we systematically and quantitatively investigated ten critical properties of where, when, and how context modulates recognition including amount of context, context and object resolution, geometrical structure of context, context congruence,  time required to incorporate contextual information, and temporal dynamics of contextual modulation. The tasks involve recognizing a target object surrounded with context in a natural image. As an essential benchmark, we first describe a series of psychophysics experiments, where we alter one aspect of context at a time, and quantify human recognition accuracy. To computationally assess performance on the same tasks, we propose a biologically inspired context aware object recognition model consisting of a two-stream architecture. The model processes visual information at the fovea and periphery in parallel, dynamically incorporates both object and contextual information, and sequentially reasons about the class label for the target object. Across a wide range of behavioral tasks, the model approximates human level performance without retraining for each task, captures the dependence of context enhancement on image properties, and provides initial steps towards integrating scene and object information for visual recognition. Some sample stimulus of psychophysics experiments are shown below.


| [![ExpA2: Amount of Context](samples/expA2.gif)](samples/expA2.gif)  | [![ExpB1: Blurred Context](samples/expB1.gif)](samples/expB1.gif) |[![ExpB4: Jigsaw Context](samples/expB4.gif)](samples/expB4.gif)  |
|:---:|:---:|:---:|
| ExpA2: Amount of Context | ExpB1: Blurred Context | ExpB4: Jigsaw Context | 

| [![ExpB5: Incongruent Context](samples/expB5.gif)](samples/expB5.gif)  | [![ExpC2: Backward Masking](samples/expC2.gif)](samples/expC2.gif) |[![ExpC3: Asynchronous Context Presentation](samples/expC3.gif)](samples/expC3.gif)  |
|:---:|:---:|:---:|
| ExpB5: Incongruent Context | ExpC2: Backward Masking | ExpC3: Asynchronous Context Presentation | 

## Dataset

Download the stimulus set from [HERE](https://drive.google.com/open?id=1pBYbFrnqy-MIzPiL_6M4z3mlW4-Ip1Rq), unzip all the image folders and place them in folder ```Matlab/Stimulus/```

Download csv files from [HERE](https://drive.google.com/open?id=17nngPM0xOL-4pL0qoka3X4eFFn8qbZ2Z) and place the folder ```csv``` in folder ```mturk/ProcessMturk/```

Download SQL database files (.db) from [HERE](https://drive.google.com/open?id=1LBFRi_3zIX5M6vk7k4vKnTDqjHV9OIIS) and place the folder ```db``` in folder ```mturk/ProcessMturk/```

Download matlab files (.mat) from [HERE](https://drive.google.com/open?id=19pjK5eSIc6yw6aatyVDOcdCs8Q4KDs9H) and place the folder ```Mat``` in folder ```mturk/ProcessMturk/```

Donwload the MSCOCO dataset ***2014*** train and val image sets from their official webiste [HERE](http://cocodataset.org/#download).


## Computational Model - CATNet

### Pre-requisite

The code has been successfully tested in Ubuntu 18.04 with one GPU (NVIDIA RTX 2080 Ti). It requires the following:
- PyTorch = 1.1.0 
- python = 2.7
- CUDA = 10.2
- torchvision = 0.3.0

Dependencies:
- numpy
- opencv
- scipy
- matplotlib
- skimage

Refer to [link](https://www.anaconda.com/distribution/) for Anaconda installation. Alternatively, execute the following command:
```
curl -O https://repo.anaconda.com/archive/Anaconda3-2019.03-Linux-x86_64.sh
bash Anaconda3-2019.03-Linux-x86_64.sh
```
After Anaconda installation, create a conda environment:
```
conda create -n pytorch27 python=2.7
```
Activate the conda environment:
```
conda activate pytorch27
```
In the conda environment, refer to [link](https://pytorch.org/get-started/locally/) for Pytorch installation.

Download our repository:
```
git clone https://github.com/kreimanlab/Put-In-Context.git
```

Download our pre-trained model from [HERE](https://drive.google.com/open?id=16So2IEG5Ct68MJ7w3W7TZP1E1J_8g_iL) and place the downloaded model ```checkpoint_2.pth.tar``` in folder ```pytorch/recurrentVA_lstm/models/```



## Human Mouse Clicking Experiments on Amazon Mechanical Turk 

We designed a series of Mturk experiments using [Psiturk](https://psiturk.org/) which requires javascripts, HTML and python 2.7. The source codes have been successfully tested on MAC OSX and Ubuntu 18.04. See sections below for installation, running the experiments locally and launching the experiments online.

### Installation of Psiturk

Refer to [link](https://www.anaconda.com/distribution/) for Anaconda installation. Alternatively, execute the following command:
```
curl -O https://repo.anaconda.com/archive/Anaconda3-2019.03-Linux-x86_64.sh
bash Anaconda3-2019.03-Linux-x86_64.sh
```
After Anaconda installation, create a conda environment:
```
conda create -n mturkenv python=2.7
```
Activate the conda environment:
```
conda activate mturkenv
```
Install psiturk using pip:
```
pip install psiturk
```
Refer to [HERE](https://drive.google.com/open?id=1FblDG7OuWXVRfWo0Djb5eDiYgKqnk9wU) for detailed instruction on setting up psiturk key and paste them in .psiturkconfig.

### Running the experiment locally

Navigate to any experiments in ```mturk/Mturk/``` folder. In the following, we take experiment A as an example, one can replace it with any other experiments. Open a command window, navigate to ```mturk/Mturk/expA_what```, and run the experiment in debug mode:
```
cd mturk/Mturk/expA_what
psiturk
server on
debug
```
**NOTE** You can run the source codes directly. All the stimulus set have been hosted in our lab server: http://kreiman.hms.harvard.edu/mturk/mengmi/. One can freely view any stimulus via Internet, e.g. http://kreiman.hms.harvard.edu/mturk/mengmi/expA_what_data/sample_7.gif. In case, the links are unavailable. One can generate the whole stimulus set for each experiment by running ```Matlab/demo_expA.m```

We now list a detailed description of important source files:
- expF_click.db: a SQL database storing online subjects' mouse clicking data. See evaluation codes above for converting db file to MATLAB struct for result analysis.
- instructions/instruct-1.html: show instructions to the human subjects
- static/js/task.js: main file to load stimulus and run the experiment
- static/js/bubbleview.js: all supporting functions to put multiple canvas on the original image and create bubble views

### Launching the experiment online using Elastic Cloud Computing (EC2) in Amazon Web Services (AWS)

Copy the downloaded source codes to EC2 server and run the psiturk experiment online. Refer to [HERE](https://drive.google.com/open?id=1FblDG7OuWXVRfWo0Djb5eDiYgKqnk9wU) for detailed instruction

## Notes

The source code is for illustration purpose only. Path reconfigurations may be needed to run some MATLAB scripts. We do not provide techinical supports but we would be happy to discuss about SCIENCE!

## License

See [Kreiman lab](http://klab.tch.harvard.edu/code/license_agreement.pdf) for license agreements before downloading and using our source codes and datasets.
