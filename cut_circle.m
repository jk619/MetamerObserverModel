clc
clear

mainPath            = fullfile(fileparts(mfilename('fullpath')));
windowPath          = fullfile(mainPath,'windows');
codePath            = fullfile(mainPath,'functions');
targetPath          = fullfile(mainPath,'target_images');

addpath(genpath(codePath));

w.size      = 2048;
images = dir(sprintf('%s/*.png',targetPath));


for i = 1% : length(images)
    
    oim = im2uint8(imread([images(i).folder filesep images(i).name]));
    sz = size(oim);
    mysize_pow_two =  log2(w.size);
    cropx = (sz(1)-2^mysize_pow_two) / 2;
    cropy = (sz(2)-2^mysize_pow_two) / 2;
    oim = oim(cropx+1:sz(1)-cropx,cropy+1:sz(2)-cropy,:);
    
    imageSize = size(oim);
    ci = [1024, 1024+500, 200];     % center and radius of circle ([c_row, c_col, r])
    [xx,yy] = ndgrid((1:imageSize(1))-ci(1),(1:imageSize(2))-ci(2));
    mask = uint8((xx.^2 + yy.^2)<ci(3)^2);
    croppedImage = oim.*mask;
    croppedImage(croppedImage==0) = 128;
    croppedImage = double(croppedImage);
    

    
end


figure(1);clf
imagesc(croppedImage)