clc
clear

mainPath            = fullfile(fileparts(mfilename('fullpath')));
windowPath          = fullfile(mainPath,'windows');
codePath            = fullfile(mainPath,'functions');
targetPath          = fullfile(mainPath,'target_images');

addpath(genpath(codePath));

myimage             = 'llama';

w.scaling           = 0.84;
w.aspect            = 2;
w.size              = 2048;

%% load windows


load(sprintf('%s/window_2048x2048_s=%.2f_a=%i.mat',windowPath,w.scaling,w.aspect))

oim                 = double(im2uint8(imread([targetPath filesep myimage '.png'])));
sz                  = size(oim);
mysize_pow_two      =  log2(w.size);
cropx               = (sz(1)-2^mysize_pow_two) / 2;
cropy               = (sz(2)-2^mysize_pow_two) / 2;
oim                 = oim(cropx+1:sz(1)-cropx,cropy+1:sz(2)-cropy,:);

params 		        = metamerAnalysis(oim,m,opts);
[Out, ~]            = collectParams(params,opts);
[mask, maskInds]    = collectParamMask(opts,params); % Get parameter mask
[Out_masked]        = Out(mask,:); % Mask out duplicate parameters

save(sprintf('%s/params_%s_s=%.2f_a=%i.mat',targetPath,myimage,w.scaling,w.aspect),'Out_masked');

disp('Complete!');


