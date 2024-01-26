% Generate plots for Fig1c
% from:
% Opposing effects of selectivity and invariance in peripheral vision
% Corey M Ziemba & Eero P Simoncelli


%% 4-PANEL TEXTURE DEMO (will take <1min per iteration)
%
clc
close all
clear all
mainPath = '/Volumes/server/Projects/opposingEffects';
addpath(genpath(mainPath))


o.scaling       = 0.46; % pooling region scaling values: 0.21; 0.46; 0.84
o.imSizes       = 2048;



% load original image ancd crop to square

im1 = 'llama_gamma-False.png';
oim = double((imread(im1)));
sz = size(oim);
mysize_pow_two =  log2(o.imSizes);
cropx = (sz(1)-2^mysize_pow_two) / 2;
cropy = (sz(2)-2^mysize_pow_two) / 2;
oim1 = oim(cropx+1:sz(1)-cropx,cropy+1:sz(2)-cropy,:);


im2 = 'seed-1_init-azulejos.png';
oim = double((imread(im2)));
sz = size(oim);
mysize_pow_two =  log2(o.imSizes);
cropx = (sz(1)-2^mysize_pow_two) / 2;
cropy = (sz(2)-2^mysize_pow_two) / 2;
oim2 = oim(cropx+1:sz(1)-cropx,cropy+1:sz(2)-cropy,:);


figure(1);clf
subplot(1,2,1);
imagesc(oim1)
subplot(1,2,2);
imagesc(oim2);

opts = metamerOpts(oim1,'windowType=radial',sprintf('scale=%.2f',o.scaling),'aspect=2');






%%
% make windows
tic
m = mkImMasks(opts);
toc
%%
% do metamer analysis  (measure statistics)
tic
params = metamerAnalysis(oim1,m,opts);
toc

[tmpOut, ~]         = collectParams(params,opts);
[mask, maskInds]    = collectParamMask(opts,params); % Get parameter mask
tmpOut1             = tmpOut(mask,:); % Mask out duplicate parameters



tic
params = metamerAnalysis(oim2,m,opts);
toc

[tmpOut, ~]         = collectParams(params,opts);
tmpOut2             = tmpOut(mask,:); % Mask out duplicate parameters





%%
% Linearize the model responses, divide by the standard deviation
% over Van Hateren linearized responses
% clear allRespN
% loadPath    = fullfile(mainPath,'simulations');
% normParamsSaveFile  = fullfile(loadPath, sprintf('normParams_moments_masked&linearized.mat'));
% 
% load(normParamsSaveFile);
% 
% mu      = normParamsMean;
% sigma   = normParamsStd;
% z = allRespReshape';
% 
% allRespReshapeN     = cat(2,z(:,1:30),sqrt(abs(z(:,31:end))) .* sign(z(:,31:end)));
% allRespReshapeN     = bsxfun(@rdivide, allRespReshapeN, sigma);

allResp{1}(1,1,1,:,:) = tmpOut1;
allResp{1}(1,1,2,:,:) = tmpOut2;

%%
% inParams.o              = o;
inParams.imTexPairs     = [1    2];
inParams.inds           = maskInds; % orig inds or maskInds
inParams.scale          = opts.windows.scale;
inParams.normVanHat     = 1; 
inParams.normRFParams   = 0;
inParams.scaleNoise     = 0;
inParams.scaleWeights   = 0;    % 0 or maskScaleFile
inParams.singlePool     = 0;
inParams.paramGroups    = 'notPixelsAndMags'; %'notPixels', %'notPixelsAndMags',
inParams.thresh         = 0;    %0.01
inParams.paramNorm      = 3;    % 1 = within params, across RFs; 2 = within RFs, across params; 3 = across params/RFs; 4 = none
inParams.intN           = 0;    % amount of internal noise
inParams.lateN          = 0;    % amount of late noise
inParams.nTrials        = 2500;   % number of trials per condition; 2500 final version


% if o.scaling == 0.21
%     midN    = sqrt([(0.007^2)*4  0.007^2 (0.007^2)/4]); %V1 .5 SNR (*2/*0.5)
% elseif o.scaling == 0.46
    midN    = sqrt([(0.0114^2)*4 0.0114^2 (0.0114^2)/4]); %V2 .5 SNR (*2/*0.5)
% elseif o.scaling == 0.84
%     midN    = sqrt([(0.0128^2)*4 0.0128^2 (0.0128^2)/4]); %V4 .5 SNR (*2/*0.5)
% end

%%

figure(2);clf

for iP = 1:3
    inParams.midN   = midN(iP);
    
    [sampPerf, dists] = getPerf2afc(allResp,inParams);
       
    
    for iD=1:size(sampPerf,2)
        tmpSP   = reshape(permute(sampPerf(:,iD,:,:),[3 1 4 2]),size(sampPerf,3),size(sampPerf,1)*size(sampPerf,4));
        errorbar(iP,nanmean(tmpSP,2),std(tmpSP,[],2)./sqrt(size(tmpSP,2)),'LineWidth',2,'Color',[0 0 0])
        hold on
        drawnow
    end
    
%     inParams.logPlot    = 0;
%     axes('position',[figXPos(iP) .15 .2 .7]);
%     plotModelPerf2afc(sampPerf,famPerf,inParams);
end

xticks([1 2 3])
xticklabels(midN)
ylim([0 1])
xlabel('Amount of added noise')

title(sprintf('%s vs %s scaling = %.2f',im1,im2,o.scaling),'Interpreter','None')
ylabel('Performance')
set(gca, 'FontSize', 25)
xlim([0.5 length(midN)+0.5])

return
%% METAMER DEMO (will take a few min per iteration)
%
% This version uses windows that tile the image in
% polar angle and log eccentricity, with parameters
% used to generate metamers in Freeman & Simoncelli

% load original image
oim = double(imread('example-im-512x512.png'));

% set optionsiTex
opts = metamerOpts(oim,'windowType=radial','scale=0.5','aspect=2');

% make windows
m = mkImMasks(opts);

% plot windows
plotWindows(m,opts);

% do metamer analysis on original (measure statistics)
params = metamerAnalysis(oim,m,opts);
[tmpOut, inds]      = collectParams(params,opts);

