
%% 4-PANEL TEXTURE DEMO (will take <1min per iteration)
%
clc
close all
clear all
mainPath = '/Volumes/server/Projects/opposingEffects';
windowPath = sprintf('%s/windows/',mainPath)
addpath(genpath(mainPath))


scalings      = [0.21 0.46 0.84];
imSizes       = 2048;
aspect        = 2;

output = cell(1,length(scalings));


for s = 1 : length(scalings)
    
    opts = metamerOpts(rand(imSizes ,imSizes ),'windowType=radial',sprintf('scale=%.2f',scalings(s)),sprintf('aspect=%i',aspect));
    m = mkImMasks(opts);
    filename = sprintf('window_%ix%i_s=%.2f_a=%i.mat',imSizes,imSizes,scalings(s),aspect);
    save(sprintf('%s/%s',windowPath,filename),'m','opts','-v7.3');
    
    
end

%
% for s = 1 : length(scalings)
%
%     m = output{s};
%     filename = sprintf('window_%ix%i_s=%.2f_a=%i.mat',imSizes,imSizes,scalings(s),aspect);
%     save(sprintf('%s/%s',windowPath,filename),'m','opts','-v7.3');
%
% end
