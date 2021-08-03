# Putting Visual Object Recognition in Context

Authors: Mengmi Zhang, Claire Tseng, Gabriel Kreiman

This repository contains an implementation of a recurrent attention deep learning model for recognizing objects in complex backgrounds in natural scenes. Our paper has been accepted in CVPR 2020.

Access to our unofficial manuscript [HERE](https://arxiv.org/pdf/1911.07349.pdf), supplementary material [HERE](https://91f51bbc-dd64-485b-bf6c-40ee535dfec0.filesusr.com/ugd/d2b381_d398310448f545ca8403048958e4557a.pdf), poster [HERE](https://91f51bbc-dd64-485b-bf6c-40ee535dfec0.filesusr.com/ugd/d2b381_85d9e197211c496dab2596fcef79eea5.pdf) and presentation video [HERE](https://www.youtube.com/watch?v=ZpoUajxZPNY).

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

### Train and Test Set 

Generate all training images for computational model (CATNet) by running the script ```Matlab/Color_GenerateMSCOCOtrainTFmodel.m```. Examples of training images have been stored in ```Datasets/MSCOCO/``` for visualization.

Generate text files listing all training images (to be loaded to pytorch for training) by running the script ```Matlab/Color_GenerateMSCOCOtrainDatalist.m```. The script create all text (.txt) files and store them in ```Datalist/```. One can navigate to ```Datalist/``` to check out all those .txt files.

We used the images for psychophysics expeirments to test computational models. To generate these images, run ```Matlab/demo_expA.m```, ```Matlab/demo_expB.m```, and so on. The experiment naming conventions in the source codes matching with the expeirment definitions in the paper are listed here:
* expA: expA1, expA2
* expB: expC1, expC2
* expC: expB1
* expD: expB2
* expE: expB3, expB4
* expH: expB5
* expG: expC3

To have a quick idea of how generated test images look like, examples of generated test images for experiment A have been stored in ```Matlab/Stimulus/keyframe_expA/```. Running ```Matlab/demo_expA.m``` also generates corresponding stimulus (.gif) files for presentation on Amazon Mechanical Turk. See ```samples``` folder for examples of GIF files.

## Computational Model - CATNet

We provide both human behaviral and computational evidences that context is important for recognition. See below for a teaser image showing human-CATNet performance comparision under two context conditions.

![Novel objects](samples/CVPR_teaserimg.gif)

The teaser image containing two examples (row 1: full context; row 2: minimal context ). Column 1: ground truth, Column 2: human psychophysics trial; Column 3: attention map and label predicted by our proposed computational model

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
### Train our model
Run the following in the command window:
```
cd pytorch/recurrentVA_obj/
python train.py
```
### Test our model

Download our pre-trained model from [HERE](https://drive.google.com/file/d/1RBHC1IDLVRNEiuO7qk3sWEf5HeHIyMRp/view?usp=sharing) and place the downloaded model ```checkpoint_4.pth.tar``` in folder ```pytorch/recurrentVA_obj/models/```

Test the pre-trained model donwloaded on experiment A and B. Modify line 25 in ```pytorch/recurrentVA_obj/eval_exp.py``` 
```
expname = 'expA'; #choose one: expA, expC, expD, expE, expH
```
Run the test script in command window:
```
cd pytorch/recurrentVA_obj/
python eval_exp.py
```
Test the pre-trained model donwloaded on experiment C1.
```
cd pytorch/recurrentVA_obj/
python eval_expB.py
```
Test the pre-trained model donwloaded on experiment C2 and C3.
```
cd pytorch/recurrentVA_obj/
python eval_expG.py
```
***NOTE*** Paths and directories in these scripts might need to be modified before training or testing.

### Evaluate our model

Start Matlab and navigate current directory to ```mturk/ProcessMturk/```. 

Run ```ProcessModel_expACDEH_clicknet.m``` to generate evaluation results on exp A and B. 

Run ```ProcessModel_expB_clicknet.m``` and ```ProcessModel_expG_clicknet.m``` to generate evaluation results on exp C. 

***NOTE*** The script saves the results based on the model name. For our model, change to the following in these evaluation scripts: 
```
save(['Mat/clicknet_noalphaloss_' expname '.mat'],'mturkData');
```

To plot results, run ```PlotExpA_model.m``` to plot results for expA. Similarly for other experiments. To re-produce the exact results in our CVPR paper, run ```CVPR_expAll.m```. 

***NOTE*** One has to properly select the correct computational model. One can change the variable ```modelselect = 13;``` to produce results for different computational models.

## Human Psychophysics Experiments on Amazon Mechanical Turk 

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
Install psiturk using pip.

**Note** Psiturk has upgraded to python3. Please use the following to install psiturk for python2 version (source code on mturk experiments in this repository only works on python2 version):
```
pip install --upgrade psiturk==2.3.12
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
**NOTE** You can run the source codes directly. All the stimulus set (all GIF files) have been hosted in our lab server: http://kreiman.hms.harvard.edu/mturk/mengmi/. One can freely view any stimulus (.gif) via Internet, e.g. http://kreiman.hms.harvard.edu/mturk/mengmi/expA_what_data/sample_7.gif. In case that the links are unavailable, one can generate the whole stimulus set for each experiment by running ```Matlab/demo_expA.m``` and so on. Refer to Dataset section above for detailed instructions on generating all GIF files for all expeirments.

We now list a detailed description of important source files:
- mturk/ProcessMturk/expA.db: a SQL database storing online subjects' response data. 
- instructions/instruct-1.html: show instructions to the human subjects
- static/js/task.js: main file to load stimulus and run the experiment

It is optional to re-process these .db files. Since all the pre-processed results have been stored in ```mturk/ProcessMturk/Mat/```. If one wants to re-convert these .db files to .mat files. For each experiment, one can run ```mturk/ProcessMturk/ProcessDBfile_expB.m``` and ```mturk/ProcessMturk/CompileAllExpB.m```.

To plot results for human performance, one can either plot the results for individual experiment using the scripts ```mturk/ProcessMturk/PlotExpB.m``` and so on. Alternatively, run ```CVPR_expAll.m``` and change variable ```modelselect = 1;``` for mturk selection.

### Launching the experiment online using Elastic Cloud Computing (EC2) in Amazon Web Services (AWS)

Copy the downloaded source codes to EC2 server and run the psiturk experiment online. Refer to [HERE](https://drive.google.com/open?id=1FblDG7OuWXVRfWo0Djb5eDiYgKqnk9wU) for detailed instruction.

### Errata

There is a bug in Matlab code ```mturk/ProcessMturk/CompileAllExp*.m```; we have fixed them and updated the code for the latest version. All the original conclusions in the paper remain the same. 

## Notes

The source code is for illustration purpose only. Path reconfigurations may be needed to run some MATLAB scripts. We do not provide techinical supports but we would be happy to discuss about SCIENCE!

## License

See [Kreiman lab](http://klab.tch.harvard.edu/code/license_agreement.pdf) for license agreements before downloading and using our source codes and datasets.
