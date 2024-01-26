function [oimScreen] = getStimPlacement(ecc,imSize)
%%
szy             = 640;
szx             = 640;
blankScreen     = nan*ones(szy,szx);

o.imScale       = 80; % scale of image diameter in pixels/deg
o.ecc           = ecc;
o.imSize        = imSize;

o.eccBlur       = 0; % 1 for MTF, 2 for midget ganglion cells;
o.slopeRFsz     = 0.4/50; % scaling for midget ganglion cells


finalmask       = mkDisc(o.imSize,.95*(o.imSize)/2,[(o.imSize+1)/2 (o.imSize+1)/2],(o.imSize)/16,[1 0]);
screenOrigin    = [(szy+1)/2 64-o.ecc*o.imScale];

res     = ones(o.imSize,o.imSize);
oim     = res.*finalmask;% * 63 + 255/2;
% oim     = clip(oim,0,255);

yScreenInds = ceil(screenOrigin(1)-size(oim,1)/2):ceil(screenOrigin(1)+size(oim,1)/2)-1;
xScreenInds = ceil(screenOrigin(2)+o.ecc*o.imScale):ceil(screenOrigin(2)+o.ecc*o.imScale)+size(oim,1)-1;
oimScreen   = blankScreen;
oimScreen(yScreenInds,xScreenInds)  = oim;
oimScreen(isnan(oimScreen))     = 0;%127.5;

if o.eccBlur == 1
    M = eccMTF(oimScreen,'plot',1,'norm',0,'imCent',[o.ecc+szy/(2*o.imScale)-(64/o.imScale) 0],'stimSi',szy/o.imScale,'nEccBands',30);
    drawnow;
elseif o.eccBlur == 2
    foveaCenter = fliplr(screenOrigin - (szy+1)/2);
    M   = spatial_variant_filter(oimScreen,3,o.slopeRFsz,0,foveaCenter);
    clf,imshow(M),caxis([0 255]),colormap gray; drawnow;
else
    M = oimScreen;
end

