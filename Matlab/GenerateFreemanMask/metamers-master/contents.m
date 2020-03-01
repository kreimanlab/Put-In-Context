Contents:

Main
-----------------------------------------
metamerTest.m - test script showing basic functionality
metamerOpts.m - create structure with options
metamerAnalysis.m - compute model parameters on an image
metamerSynthesis.m - synthesize a new image

Analysis
-----------------------------------------
wmean2.m - weighted mean
wmean2crop.m - weighted mean (of cropped image)
wvar2.m - weighted variance
wskew2.m - weighted skew
wkurt2.m - weighted kurtosis
wacorr2.m - weighted auto correlation
wrange2.m - weighted range

Synthesis
-----------------------------------------
wmodmean2.m - adjust weighted mean
wmodvar2.m - adjust weighted variance
wmodskew2.m - adjust weighted skew
wmodkurt2.m - adjust weighted kurtosis
wmodacorr2.m - adjust weighted auto correlation
wmodrange2.m - adjust weighted range
adjustCorr1s.m - adjust cross-correlations
adjusteCorr2s.m - adjust multiple cross-correlations

Windows
-----------------------------------------
mkImMasks.m - make tiling window functions
mkMasksRadial.m - windows to tile angle and log ecc
mkMasksSquare.m - windows to tile x-y
mkWinFunc.m - make 1D window functions
mkWinFuncLog.m - make log 1D window functions
plotWindows.m - plot the window functions

Helper
-----------------------------------------
collectParams.m - store parameters in a matrix
findZeros.m - finds non-zero region of an image
textWaitbar.m - display time to completion
vector.m - vectorize a matrix
shrink.m - downsample an image
expand.m - upsample an imagexw
evalargs.m - argument parser
ieNotDefined.m - variable checker

