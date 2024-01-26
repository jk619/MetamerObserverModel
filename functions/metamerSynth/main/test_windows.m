% Generate plots for Fig1c
% from:
% Opposing effects of selectivity and invariance in peripheral vision
% Corey M Ziemba & Eero P Simoncelli

addpath(genpath('/Volumes/server/Projects/opposingEffects/code'));
%% 4-PANEL TEXTURE DEMO (will take <1min per iteration)
%
clc
close all
clear all
% This version of the model computes parameters within nine windows that
% tile the image. It is NOT the same as the model used in the paper,
% but runs substantially faster, so is a good way to make sure 
% that the code is working. The resulting synthetic image should reproduce the
% texture of the original within coarse square tiles.

% load original image
oim = double(rgb2gray(imread('llama.tiff')));
sz = size(oim);
cropx = (sz(1)-2^11) / 2;
cropy = (sz(2)-2^11) / 2;

oim = oim(cropx+1:sz(1)-cropx,cropy+1:sz(2)-cropy,:);
% oim = oim()

% oim = imresize(oim,[2^12 2^12]);
% oim = imresize(oim,[512 512]);
% 
% set options
opts = metamerOpts(oim,'windowType=radial','scale=0.5','aspect=2');
opts = metamerOpts(oim,'windowType=radial','scale=2','aspect=2');

% opts = metamerOpts(oim,'windowType=square','nSquares=[2,2]')
% make windows
m = mkImMasks(opts);


%%
close all
masknum = 10;
for s = 1 : length(m.scale)
    
    subplot(2,3,s)
    mymask = squeeze(m.scale{s}.maskMat(masknum,:,:));
    sz = size(mymask);
    imagesc(mymask);
    title(sprintf('Scale %i (%i x %i), maskNum = %i',s,sz(1),sz(2),masknum))
end