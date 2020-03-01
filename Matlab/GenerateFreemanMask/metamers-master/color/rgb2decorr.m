function [out T rgbMeans] = rgb2decorr(rgb)

% rgb2decorr(rgb), takes an M x M x 3 rgb input and uses the svd to decorrelate it
% returns image with decorrelated color channels, means, and transformation matrix

sz = size(rgb,1);

r = vector(rgb(:,:,1));
g = vector(rgb(:,:,2));
b = vector(rgb(:,:,3));

rgb = [r,g,b];
rgbMeans = mean(rgb);
rgb = bsxfun(@minus,rgb,rgbMeans);

C = rgb'*rgb;
[U S V] = svd(C);
T = U*S^(-1/2);
xyz = rgb*T;

out(:,:,1) = reshape(xyz(:,1),sz,sz);
out(:,:,2) = reshape(xyz(:,2),sz,sz);
out(:,:,3) = reshape(xyz(:,3),sz,sz);

