function [mask, maskInds] = collectParamMask(opts,params)

if exist('params','var')
    s = params;
else
    m   = mkImMasks(opts);
    s   = metamerAnalysis(rand(opts.szx,opts.szy),m,opts);
end

% nMasks  = size(s.pixelStats,2);
Nsc     = opts.Nsc;
Nor     = opts.Nor;
Na      = opts.maxNa;

%% PROBLEM with some sizes where last mask does not have a full covariance
maskSize = nan*zeros(1,numel(s.autoCorrRealFull.scale{Nsc}.mask));
for iN = 1:numel(s.autoCorrRealFull.scale{Nsc}.mask)
    maskSize(iN) = numel(s.autoCorrRealFull.scale{Nsc}.mask{iN});
end
maskInds = find(maskSize==Na^2);

% pixel stats
s.pixelStats(1:4,maskInds) = true;
for i=1:Nsc
    s.LPskew.scale{i}(maskInds) = true;
end
for i=1:Nsc
    s.LPkurt.scale{i}(maskInds) = true;
end

% magnitude means
for i=1:Nsc*Nor+2
    s.magMeans.band{i}(maskInds) = true;
end

% real autocorrelation
for i=1:Nsc
    for j=maskInds
        tmp         = logical(triu(ones(size(s.autoCorrRealFull.scale{i}.mask{j})),1));
        tmpInd      = sub2ind(size(tmp),median(1:Na):Na,median(1:Na):Na);
        tmp(tmpInd) = true;
        
        s.autoCorrRealFull.scale{i}.mask{j} = tmp;
    end
end

% magnitude autocorrelations
for i=1:Nsc
    for k=1:Nor
        for j=maskInds
            tmp         = logical(triu(ones(size(s.autoCorrMagFull.scale{i}.ori{k}.mask{j})),1));
            tmpInd      = sub2ind(size(tmp),median(1:Na):Na,median(1:Na):Na);
            tmp(tmpInd) = true;
            
            s.autoCorrMagFull.scale{i}.ori{k}.mask{j} = tmp;
        end
    end
end

% cousin magnitude correlations
for i=1:Nsc
    for j=maskInds
        s.cousinMagCorr.scale{i}.mask{j} = logical(triu(ones(size(s.cousinMagCorr.scale{i}.mask{j})),1));
    end
end

% parent real correlations
for i=1:Nsc-1
    for j=maskInds
        s.parentRealCorr.scale{i}.mask{j}(:,:)      = false;
        s.parentRealCorr.scale{i}.mask{j}(1:Nor,:)  = true;
    end
end

% parent magnitude correlations
for i=1:Nsc-1
    for j=maskInds
        s.parentMagCorr.scale{i}.mask{j}(:,:) = true;
    end
end

%%
[mask, maskInds] = collectParams(s,opts);

mask                    = logical(mask(:,1));
maskInds.autoCorrReal   = maskInds.magMeans(end)+1:maskInds.magMeans(end)+sum(mask(maskInds.autoCorrReal));
maskInds.autoCorrMag    = maskInds.autoCorrReal(end)+1:maskInds.autoCorrReal(end)+sum(mask(maskInds.autoCorrMag));
maskInds.cousinMagCorr  = maskInds.autoCorrMag(end)+1:maskInds.autoCorrMag(end)+sum(mask(maskInds.cousinMagCorr));
maskInds.parentRealCorr = maskInds.cousinMagCorr(end)+1:maskInds.cousinMagCorr(end)+sum(mask(maskInds.parentRealCorr));
maskInds.parentMagCorr  = maskInds.parentRealCorr(end)+1:maskInds.parentRealCorr(end)+sum(mask(maskInds.parentMagCorr));

%%








