clc
clear


mainPath    = fullfile(fileparts(mfilename('fullpath')));
windowPath  = fullfile(mainPath,'windows');
codePath    = fullfile(mainPath,'functions');
addpath(genpath(codePath));

w.scaling   = 0.84;
imSizes     = 2048;
aspect      = 2;

if ~exist(windowPath,'dir');mkdir(windowPath);end

opts = metamerOpts(rand(imSizes ,imSizes ),'windowType=radial',sprintf('scale=%.2f',w.scaling),sprintf('aspect=%i',aspect),'Nsc=4','Nor=4');
m = mkImMasks(opts);
filename = sprintf('window_%ix%i_s=%.2f_a=%i.mat',imSizes,imSizes,w.scaling,aspect);
save(sprintf('%s/%s',windowPath,filename),'m','opts','-v7.3');

disp('Complete!');

