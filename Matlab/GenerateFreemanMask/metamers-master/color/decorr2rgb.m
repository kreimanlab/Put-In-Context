function out = decorr2rgb(oim,T,meansRGB)

% decorr2rgb(oim,T,meansRGB), takes an image made of decorrelated color channels,
% decorrelated using the matrix T, and converts it back into RGB using the inverse
% transform, and adding back in the original channel means

sz = size(oim,1);

x = vector(oim(:,:,1));
y = vector(oim(:,:,2));
z = vector(oim(:,:,3));
	
xyz = [x y z];
rgb = xyz*inv(T);

out(:,:,1) = reshape(rgb(:,1),sz,sz) + meansRGB(1);
out(:,:,2) = reshape(rgb(:,2),sz,sz) + meansRGB(2);
out(:,:,3) = reshape(rgb(:,3),sz,sz) + meansRGB(3);
