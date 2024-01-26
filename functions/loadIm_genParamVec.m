% Generate model responses from images cropped to differet sizes.
% from:
% Opposing effects of selectivity and invariance in peripheral vision
% Corey M Ziemba & Eero P Simoncelli

mainPath    = fullfile(fileparts(mfilename('fullpath')), '..','..');
addpath(genpath(mainPath));
imPath      = fullfile(mainPath,'images');

szy             = 640;
szx             = 640;
blankScreen     = nan*ones(szy,szx);

myscreen.background = 'gray';
texture             = [7; 107; 121; 126];

% o.pxPerDeg      = 1/mglGetParam('xPixelsToDevice');
o.stimType      = 'p'; %'p' for patch == cropped images, 'm' for match == synthsized images
o.imScale       = 80; % scale of image diameter in pixels/deg
o.imSizes       = [64 128 192 320 512];
o.textures      = texture;
o.samples       = 1:15;
o.ecc           = 4; %[4 8 16]; % eccentricity of target
o.texType       = 1; % 1 means texture % 2 means noise % 3 means +marginals
o.eccBlur       = 0; % 1 for MTF, 2 for midget ganglion cells;
o.slopeRFsz     = 0.4/50; % scaling for midget ganglion cells
o.rfScale       = 0.9; %phys: .21, .46, .84
o.aspectrRatio  = 2; 


mkdir(fullfile(mainPath,'simulations'),sprintf('params_sc%1.2g_p_a2/',o.rfScale)); %phys: .21, .46, .84
paramSavePath   = fullfile(mainPath,'simulations',sprintf('params_sc%1.2g_p_a2/',o.rfScale)); %phys: .21, .46, .84

% Do stuff that will be applied to all images
for iSize = 1:length(o.imSizes)
    finalmask{iSize}   = mkDisc(o.imSizes(iSize),.95*(o.imSizes(iSize))/2,[(o.imSizes(iSize)+1)/2 (o.imSizes(iSize)+1)/2],(o.imSizes(iSize))/16,[1 0]);
end

for iEcc = 1:numel(o.ecc)
    
    screenOrigin    = [(szy+1)/2 64-o.ecc(iEcc)*o.imScale];
    
    opts    = metamerOpts(blankScreen,sprintf('origin=[%f,%f]',screenOrigin),sprintf('scale=%g',o.rfScale),sprintf('aspect=%g',o.aspectrRatio));
    m       = mkImMasks(opts);
    save(fullfile(paramSavePath,'imMasks.mat'),'m','opts');
    
    for iTexNum = 1:size(o.textures,1)
        for iSamp = 1:length(o.samples)
            for iSize = 1:length(o.imSizes)
                
                saveFileName    = sprintf('meta_tex%d_ecc%g_sz%d_samp%d.mat',o.textures(iTexNum),o.ecc(iEcc),o.imSizes(iSize),o.samples(iSamp));
                fileStruct      = dir(fullfile(paramSavePath,saveFileName));
                
                if isempty(fileStruct)
                    
                    if o.texType == 1
                        fileName = sprintf('v1m-%gx%g-im%g-smp%g.mat',o.imSizes(iSize),o.imSizes(iSize),o.textures(iTexNum),o.samples(iSamp));
                    elseif o.texType == 2
                        %             fileName = sprintf('noise-320x320-im%g-smp%g.mat',o.textures(iTex),o.samples(iSamp));
                    elseif o.texType == 3
                        %             fileName = sprintf('v1m-320x320-im%g-smp%g.mat',o.textures(iTex),o.samples(iSamp));
                    end
                    load(fullfile(imPath,fileName));
                    
                    oim         = res.*finalmask{iSize} * 63 + 255/2;
                    oim         = clip(oim,0,255);
                    
                    yScreenInds = ceil(screenOrigin(1)-size(oim,1)/2):ceil(screenOrigin(1)+size(oim,1)/2)-1;
                    xScreenInds = ceil(screenOrigin(2)+o.ecc(iEcc)*o.imScale):ceil(screenOrigin(2)+o.ecc(iEcc)*o.imScale)+size(oim,1)-1;
                    oimScreen   = blankScreen;
                    oimScreen(yScreenInds,xScreenInds)  = oim;
                    oimScreen(isnan(oimScreen))     = 127.5;
                    
                    if o.eccBlur == 1
                        M = eccMTF(oimScreen,'plot',1,'norm',0,'imCent',[o.ecc(iEcc)+szy/(2*o.imScale)-(64/o.imScale) 0],'stimSi',szy/o.imScale,'nEccBands',30);
                        drawnow;
                    elseif o.eccBlur == 2                        
                        foveaCenter = fliplr(screenOrigin - (szy+1)/2);
                        M   = spatial_variant_filter(oimScreen,3,o.slopeRFsz,0,foveaCenter);
                        clf,imshow(M),caxis([0 255]),colormap gray; drawnow;
                    else
                        M = oimScreen;
                    end
                    
                    params          = metamerAnalysis(M,m,opts);
                    save(fullfile(paramSavePath,saveFileName),'params','opts');
                end
            end
        end
    end
end





