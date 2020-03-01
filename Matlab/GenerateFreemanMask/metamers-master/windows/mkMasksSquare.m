function mask = mkMasksSquare(imSize,windows,verbose)

%-----------------------------------------
% mkMasksSquare(imSize,windows)
%
% generates a family of square window functions
% that tile evenly in x and y
%
% imSize: size of image (2-vector)
% windows: structure containing window parameters
% (see initParams.m)dbcont
%
% masks: matrix of window functions
%
% freeman, 12/25/2008
%-----------------------------------------

overlap = [windows.overlap, windows.overlap];
nSquares = windows.nSquares;

imask = 1;

rX = repmat([1:imSize(1)],imSize(2),1);
rY = repmat([1:imSize(2)]',1,imSize(1));;

nX = nSquares(2);
wX = imSize(1)/nX;
twX = overlap(1)*wX;
wX = imSize(1)/nX - twX;
centX = (0:nX-1)*(wX + twX) + wX;

nY = nSquares(1);
wY = imSize(2)/nY;
twY = overlap(2)*wY;
wY = imSize(2)/nY - twY;
centY = (0:nY-1)*(wY + twY) + wY;

if verbose; T = textWaitbar('(mkMasksSquare) making windows'); end
for ix=1:nX
  [xXwin yXwin] = mkWinFunc(centX(ix),wX,twX,[0 imSize(1)]);
  if nX == 1
  	yXwin = ones(size(yXwin));
  end
  xMask = interp1(xXwin,yXwin,rX);
  for iy=1:nY
    [xYwin yYwin] = mkWinFunc(centY(iy),wY,twY,[0 imSize(2)]);
    if nY == 1
    	yYwin = ones(size(yYwin));
    end
    yMask = interp1(xYwin,yYwin,rY);
    mask(imask,:,:) = xMask.*yMask;
    imask = imask + 1;
  end
  if verbose; T = textWaitbar(T,ix/nX); end
end
