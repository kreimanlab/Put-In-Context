METAMER CODE

This package includes code used to analyze images and 
generate metamers using the model described in:

Freeman, J & Simoncelli, EP (2011) Metamers of the ventral stream.
Nature Neuroscience, 14 (9)

The model analyzes local, higher-order statistics that capture properties
of visual textures and are thought to be represented in primate area V2. 
We then synthesize images that are matched for the same local statistics, 
but are otherwise random. The local regions can be specified to tile
polar angle and log eccentricitiy (to mimic neuronal receptive fields),
or to tile the image (i.e. a square grid). Input images should be at least
512x512 pixels.

The default parameters for the model are those used in 
Freeman & Simoncelli (2012) to generate metamers (synthetic images
that differ physically, but appear the same). 

See examples.m for other uses and parameter settings.

------------------------------------------------

Code developed between 2009-2012, released 2013

Latest version availiable at http://www.jeremyfreeman.net/?l=papers&s=2011_metamers_ventral



Requires the matlabPyrTools toolbox (http://www.cns.nyu.edu/lcv/software.php)

For related work and code, see the Portilla-Simoncelli model for global texture analysis and synthesis (http://www.cns.nyu.edu/~lcv/texture/), described in:

Portilla, J & Simoncelli, EP (2001) A parametric texture model based on joint statistics of complex wavelet coefficients. International Journal of Computer Vision, 40 (1)
