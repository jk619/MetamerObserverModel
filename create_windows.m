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
% save(sprintf('%s/%s',windowPath,filename),'m','opts','-v7.3');

disp('Complete!');

tmp         = imread('./target_images/azulejos.png');
values      = [1 255];
side        = {'left';'right'};
color       = 'gr';

for v = 1 : length(side)
    
    newimg = [ones(size(tmp,1),size(tmp,2)/2) ones(size(tmp,1),size(tmp,2)/2)*255];
    newimg(:,size(tmp,2)/2-50:size(tmp,2)/2+50) = values(v);
    
    sz = size(newimg);
    mysize_pow_two =  log2(imSizes);
    cropx = (sz(1)-2^mysize_pow_two) / 2;
    cropy = (sz(2)-2^mysize_pow_two) / 2;
    newimg = newimg(cropx+1:sz(1)-cropx,cropy+1:sz(2)-cropy,:);
                
    
    params = metamerAnalysis_w(newimg,m,opts,1);
    params.pixelStats = params.pixelStats(1,:);
    
    %%
    
    if v == 1

        newimg = [ones(size(tmp,1),size(tmp,2)/2) ones(size(tmp,1),size(tmp,2)/2)*255];
        newimg(:,size(tmp,2)/2-50:size(tmp,2)/2+50) = 128;
        sz = size(newimg);
        mysize_pow_two =  log2(imSizes);
        cropx = (sz(1)-2^mysize_pow_two) / 2;
        cropy = (sz(2)-2^mysize_pow_two) / 2;
        newimg = newimg(cropx+1:sz(1)-cropx,cropy+1:sz(2)-cropy,:);
        imagesc(newimg)
        
    end
    colormap gray
    hold on
    windowindex.(sprintf('%s',side{v})) = find((params.pixelStats) == values(v));
    
    for i = 1 : length(windowindex.(sprintf('%s',side{v})))
        contour(squeeze(m.scale{1}.maskMat(windowindex.(sprintf('%s',side{v}))(i),:,:)),1,color(v))
        hold  on
    end
    
    
end

opts.indices = windowindex;
save(sprintf('%s/window_2048x2048_s=%.2f_a=%i.mat',windowPath,w.scaling,aspect),'m','opts','-v7.3')
