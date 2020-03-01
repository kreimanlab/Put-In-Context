function [indices minBoundBox numNonZero] = findZeros(mat);

%
%-----------------------------------------
% [indices minBoundBox numNonZero] = findZeros(mat)
%
% finds a square that is a power of 2 in size
% and includes the non-zero portions of
% the input matrix
%
% mat: input matrix
%
% indices: indices into the square
%
% freeman, 3/25/2009
%-----------------------------------------

szx = size(mat,1);
szy = size(mat,2);

[rowind colind] = find(mat>0);

numNonZero = length(rowind);

rowBounds(1) = min(rowind);
rowBounds(2) = max(rowind);
colBounds(1) = min(colind);
colBounds(2) = max(colind);

szBoundBox = max(diff(rowBounds)+1,diff(colBounds)+1);

if szBoundBox == 1
  szBoundBox = 2;
end

if ~mod(szBoundBox,2)
  minBoundBox = szBoundBox - 1;
else
  minBoundBox = szBoundBox;
end

szBoundBox = 2^ceil(log2(szBoundBox))-1; % might want to make ceil instead

if szBoundBox + 1 > szx
  szBoundBox = szx - 1;
end  

if (rowBounds(1)+szBoundBox > szx) & (colBounds(1)+szBoundBox <= szy)
	indices = [szx-szBoundBox,szx,colBounds(1),colBounds(1)+szBoundBox];
elseif (colBounds(1)+szBoundBox > szy) & (rowBounds(1)+szBoundBox <= szx)
	indices = [rowBounds(1),rowBounds(1)+szBoundBox,szy-szBoundBox,szy];	
elseif (rowBounds(1)+szBoundBox > szx) & (colBounds(1)+szBoundBox > szy)
	indices = [szx-szBoundBox,szx,szy-szBoundBox,szy];
elseif (rowBounds(1)+szBoundBox <= szx) & (colBounds(1)+szBoundBox <= szy)
	indices = [rowBounds(1),rowBounds(1)+szBoundBox,colBounds(1),colBounds(1)+szBoundBox];
end	

indices(indices<0) = 1; % special handling for non-square cases