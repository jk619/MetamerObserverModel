function [famPerf,sampPerf,out] = genSampFamPerf2afc(allResp,inParams)
%%
mainPath    = fullfile(fileparts(mfilename('fullpath')), '..','..');
loadPath    = fullfile(mainPath,'simulations');

if inParams.normVanHat
    dims            = [size(allResp{1},1) size(allResp{1},2) size(allResp{1},3)];
    allRespReshape  = [];
    
    normParamsSaveFile  = fullfile(loadPath, sprintf('normParams_moments_masked&linearized.mat'));
    load(normParamsSaveFile);
    
    % Transfer from structure to matrix for normalization
    rfs     = zeros(1,3); eccStarts     = zeros(1,3); eccEnds   = zeros(1,3);
    for iEcc = 1:numel(allResp)
        rfs(iEcc)       = size(allResp{iEcc},5);
        tmpPermuteResp  = permute(allResp{iEcc},[1 2 3 5 4]);
        tmpRespMat      = reshape(tmpPermuteResp,dims(1)*dims(2)*dims(3)*size(tmpPermuteResp,4),size(tmpPermuteResp,5));
        eccStarts(iEcc) = size(allRespReshape,1)+1;
        eccEnds(iEcc)   = eccStarts(iEcc)+size(tmpRespMat,1)-1;
        allRespReshape  = cat(1,allRespReshape,tmpRespMat);
    end
    
    mu      = normParamsMean;
    sigma   = normParamsStd;
    z       = allRespReshape;
    
    % Linearize the model responses, divide by the standard deviation
    % over Van Hateren linearized responses
    allRespReshapeN     = cat(2,z(:,1:30),sqrt(abs(z(:,31:end))) .* sign(z(:,31:end)));
    allRespReshapeN     = bsxfun(@rdivide, allRespReshapeN, sigma);
    
    allRespN     = cell(1,numel(allResp));
    for iEcc = 1:numel(allResp)
        tmpRespMatN     = reshape(allRespReshapeN(eccStarts(iEcc):eccEnds(iEcc),:),[dims(1) dims(2) dims(3) rfs(iEcc) size(allRespReshapeN,2)]);
        allRespN{iEcc}  = permute(tmpRespMatN,[1 2 3 5 4]);
    end
else
    allRespN     = allResp;
end

%%

switch inParams.paramGroups
    case 'all'
        inParams.groupInds  = 1:size(allRespN{1},4);
    case 'notPixels'
        inParams.groupInds  = 14:size(allRespN{1},4);
    case 'notPixelsAndMags'
        inParams.groupInds  = 31:size(allRespN{1},4);
    case 'magMeans'
        inParams.groupInds  = inParams.inds.magMeans;
    case 'pixelStats'
        inParams.groupInds  = inParams.inds.pixelStats;
    case 'autoCorrReal'
        inParams.groupInds  = inParams.inds.autoCorrReal;
    case 'autoCorrMag'
        inParams.groupInds  = inParams.inds.autoCorrMag;
    case 'cousinMagCorr'
        inParams.groupInds  = inParams.inds.cousinMagCorr;
    case 'parentRealCorr'
        inParams.groupInds  = inParams.inds.parentRealCorr;
    case 'parentMagCorr'
        inParams.groupInds  = inParams.inds.parentMagCorr;
end

compInds    = nchoosek(1:15,2);
respInds    = cell(1,3);
sampPerf    = nan*zeros(size(allRespN{1},2),numel(allRespN),size(allRespN{1},1),inParams.nTrials);
withinDist  = nan*zeros(size(allRespN{1},2),numel(allRespN),size(allRespN{1},1),inParams.nTrials);
zeroDist    = nan*zeros(size(allRespN{1},2),numel(allRespN),size(allRespN{1},1),inParams.nTrials);

resetNoise  = inParams.midN;
addNoise    = .001;

tic
T=textWaitbar('Computing sample task performance'); t=1;
for iEcc = 1:numel(allRespN)
    for iS = 1:size(allRespN{iEcc},1)
        for iT = 1:size(allRespN{iEcc},2)
            tmpParams   = squeeze(allRespN{iEcc}(iS,iT,:,inParams.groupInds,:));
            % get indices for the pooling regions to include based on the
            % magnitude of spectral response
            magInds                 = inParams.inds.magMeans(1:end-1);
            tmpMagParams            = squeeze(allResp{iEcc}(iS,iT,:,:,:));
            tmpMagResp              = vec(sum(mean(tmpMagParams(:,magInds,:),1),2));
            tmpMagResp              = tmpMagResp./max(tmpMagResp);
            respInds{iEcc}(iS,iT,:) = (tmpMagResp>inParams.thresh);
            
            if inParams.normRFParams
                for iTT = 1:size(tmpParams,1)
                    paramVal            = squeeze(tmpParams(iTT,:,:));
                    tmpParams(iTT,:,:)  = bsxfun(@times,paramVal,tmpMagResp');
                end
            end
            
            if inParams.scaleNoise
                tmpMagRespThresh    = tmpMagResp(respInds{iEcc}(iS,iT,:));
                tmpNoise = (inParams.intN*randn(inParams.nTrials*size(tmpParams,2)*3,sum(respInds{iEcc}(iS,iT,:))));
                tmpNoise = bsxfun(@times,tmpNoise,tmpMagRespThresh');
                tmpNoise = reshape(tmpNoise,inParams.nTrials,size(tmpParams,2),3, sum(respInds{iEcc}(iS,iT,:)));
                tmpNoise = permute(tmpNoise,[3 2 4 1]);
            else
                tmpNoise = (inParams.intN*randn(3,size(tmpParams,2),sum(respInds{iEcc}(iS,iT,:)),inParams.nTrials));
            end
            
            if inParams.scaleWeights
                load(inParams.scaleWeights);
                scaleWeightMat  = maskScaleMat{iEcc};
                scaleWeightMat  = scaleWeightMat(:,inParams.groupInds);
                if size(scaleWeightMat,1) ~= size(tmpParams,3)
                    extraMasks      = size(tmpParams,3) - size(scaleWeightMat,1);
                    scaleWeightMat  = cat(1,scaleWeightMat,ones(extraMasks,numel(inParams.groupInds)));
                end
                inParams.scaleWeightMat  = scaleWeightMat./repmat(nansum(scaleWeightMat,2),1,size(scaleWeightMat,2)); %normalize weights across all parameters
            end
            
            % compute distance for each trial
            trials  = nan*zeros(inParams.nTrials,2);
            for iTrial=1:inParams.nTrials
                T=textWaitbar(T,t/(numel(allRespN)*size(allRespN{iEcc},1)*size(allRespN{iEcc},2)*inParams.nTrials)); t=t+1;
                
                % get parameter values for sample pairs and zeros
                distInd         = ceil(size(compInds,1)*rand); % randomly sample within category distances
                tmpTexA         = squeeze(tmpParams(compInds(distInd,1),:,respInds{iEcc}(iS,iT,:)));
                tmpTexB         = squeeze(tmpParams(compInds(distInd,2),:,respInds{iEcc}(iS,iT,:)));
                
                [respN, respS] = getFullResp(tmpTexA,tmpTexA,tmpTexB,tmpNoise(:,:,:,iTrial),inParams);
                trials(iTrial,1)     = respN;
                trials(iTrial,2)     = respS;
            end
            
            
            trials  = trials + inParams.lateN*randn(size(trials));
            
            [~,b]                       = min(trials,[],2);                   % find the interval with minimum distance
            sampPerf(iT,iEcc,iS,:)      = (b == 1);                           % get performance (correct is always first 0 distance interval)
            withinDist(iT,iEcc,iS,:)    = trials(:,2);
            zeroDist(iT,iEcc,iS,:)      = trials(:,1);
        end
    end
end
toc
out.withinDist  = withinDist;
out.zeroDist    = zeroDist;
out.withinRInds = respInds;

%%

% respInds    = cell(1,3);
% famPerf     = nan*zeros(size(allRespN{iEcc},2),numel(allRespN),size(allRespN{iEcc},1),inParams.nTrials);
% acrossDist  = nan*zeros(size(allRespN{iEcc},2),numel(allRespN),size(allRespN{iEcc},1),inParams.nTrials);
% withinDist2 = nan*zeros(size(allRespN{iEcc},2),numel(allRespN),size(allRespN{iEcc},1),inParams.nTrials);
% 
% inParams.midN   = resetNoise;
% 
% tic
% T=textWaitbar('Computing family task performance'); t=1;
% for iEcc = 1:numel(allRespN)
%     for iS = 1:size(allRespN{iEcc},1)
%         for iT = 1:size(inParams.imTexPairs,1)
%             tmpParams   = squeeze(allRespN{iEcc}(iS,:,:,inParams.groupInds,:));
%             % get indices for the pooling regions to include based on the
%             % magnitude of spectral response
%             magInds                 = inParams.inds.magMeans(1:end-1);
%             tmpMagParams            = squeeze(allResp{iEcc}(iS,inParams.imTexPairs(iT,:),:,:,:));
%             tmpMagResp              = vec(mean(mean(mean(tmpMagParams(:,:,magInds,:),1),2),3));
%             tmpMagResp              = tmpMagResp./max(tmpMagResp);
%             respInds{iEcc}(iS,iT,:) = (tmpMagResp>inParams.thresh);
%             
%             if inParams.normRFParams
%                 for iTT = 1:size(tmpParams,1)
%                     for iSamp = 1:size(tmpParams,1)
%                         paramVal            = squeeze(tmpParams(iTT,iSamp,:,:));
%                         tmpParams(iTT,iSamp,:,:)  = bsxfun(@times,paramVal,tmpMagResp');
%                     end
%                 end
%             end
%             
%             if inParams.scaleNoise
%                 tmpMagRespThresh    = tmpMagResp(respInds{iEcc}(iS,iT,:));
%                 tmpNoise = (inParams.intN*randn(inParams.nTrials*size(tmpParams,3)*3,sum(respInds{iEcc}(iS,iT,:))));
%                 tmpNoise = bsxfun(@times,tmpNoise,tmpMagRespThresh');
%                 tmpNoise = reshape(tmpNoise,inParams.nTrials,size(tmpParams,3),3, sum(respInds{iEcc}(iS,iT,:)));
%                 tmpNoise = permute(tmpNoise,[3 2 4 1]);
%             else
%                 tmpNoise = (inParams.intN*randn(3,size(tmpParams,3),sum(respInds{iEcc}(iS,iT,:)),inParams.nTrials));
%             end
%             
%             if inParams.scaleWeights
%                 load(inParams.scaleWeights);
%                 scaleWeightMat  = maskScaleMat{iEcc};
%                 scaleWeightMat  = scaleWeightMat(:,inParams.groupInds);
%                 if size(scaleWeightMat,1) ~= size(tmpParams,4)
%                     extraMasks      = size(tmpParams,4) - size(scaleWeightMat,1);
%                     scaleWeightMat  = cat(1,scaleWeightMat,ones(extraMasks,numel(inParams.groupInds)));
%                 end
%                 inParams.scaleWeightMat  = scaleWeightMat./repmat(nansum(scaleWeightMat,2),1,size(scaleWeightMat,2)); %normalize weights across all parameters
%             end
%             
%             % compute distance for each trial
%             trials  = nan*zeros(inParams.nTrials,2);
%             for iTrial = 1:inParams.nTrials
%                 T=textWaitbar(T,t/(numel(allRespN)*size(allRespN{iEcc},1)*size(inParams.imTexPairs,1)*inParams.nTrials)); t=t+1;
%                 
%                 % get info for current trial
%                 wT          = randperm(2);                                  % determine which texture will have 2 samples presented
%                 wS          = randperm(2,1);                                % determine which sample will be the middle
%                 distInd1    = randperm(15,1);                               % get the sample used for texture 1
%                 distInd2    = sort(randperm(15,2),2);                       % get the samples used for texture 2
%                 tmpTexA     = squeeze(tmpParams(inParams.imTexPairs(iT,wT(1)),distInd2,:,respInds{iEcc}(iS,iT,:)));
%                 tmpTexB     = squeeze(tmpParams(inParams.imTexPairs(iT,wT(2)),distInd1,:,respInds{iEcc}(iS,iT,:)));
%                 
%                 [respN, respS,respParams] = getFullResp(squeeze(tmpTexA(1,:,:)),squeeze(tmpTexA(2,:,:)),tmpTexB,tmpNoise(:,:,:,iTrial),inParams);
%                 trials(iTrial,1)     = respN;
%                 trials(iTrial,2)     = respS;
%             end
%             
%             trials  = trials + inParams.lateN*randn(size(trials));
%             
%             [~,b]                       = min(trials,[],2);                     % find the interval with minimum distance
%             famPerf(iT,iEcc,iS,:)       = (b==1);                               % get performance (correct is always first within distance interval)
%             acrossDist(iT,iEcc,iS,:)    = trials(:,2);
%             withinDist2(iT,iEcc,iS,:)   = trials(:,1);
%         end
%     end
% end
% toc
% out.acrossDist  = acrossDist;
% out.withinDist2 = withinDist2;
% out.acrossRInds = respInds;

end


function [outN, outS, outR] = getFullResp(respA1, respA2, respB, tmpNoise, inParams)

tmpTexANoise    = respA1 + squeeze(tmpNoise(1,:,:));
tmpTexBNoise    = respB + squeeze(tmpNoise(2,:,:));
tmpZeroANoise   = respA2 + squeeze(tmpNoise(3,:,:));

if inParams.scaleWeights
    tmpTexANoise    = tmpTexANoise.*inParams.scaleWeightMat';
    tmpTexBNoise    = tmpTexBNoise.*inParams.scaleWeightMat';
    tmpZeroANoise   = tmpZeroANoise.*inParams.scaleWeightMat';
end

% 1 = within params, across RFs; 2 = within RFs, across params; 3 = across params/RFs; 4 = none
if inParams.paramNorm == 1 % within params, across RFs
    tmpTexANoise    = bsxfun(@rdivide,tmpTexANoise,  sqrt(sum(tmpTexANoise.^2,2)));
    tmpTexBNoise    = bsxfun(@rdivide,tmpTexBNoise,  sqrt(sum(tmpTexBNoise.^2,2)));
    tmpZeroANoise   = bsxfun(@rdivide,tmpZeroANoise,  sqrt(sum(tmpZeroANoise.^2,2)));
elseif inParams.paramNorm == 2 % within RFs, across params
    tmpTexANoise    = bsxfun(@rdivide,tmpTexANoise,  sqrt(sum(tmpTexANoise.^2,1)));
    tmpTexBNoise    = bsxfun(@rdivide,tmpTexBNoise,  sqrt(sum(tmpTexBNoise.^2,1)));
    tmpZeroANoise   = bsxfun(@rdivide,tmpZeroANoise,  sqrt(sum(tmpZeroANoise.^2,1)));
elseif inParams.paramNorm == 3 % across params/RFs
    tmpTexANoise    = bsxfun(@rdivide,tmpTexANoise,  sqrt(sum(tmpTexANoise(:).^2)));
    tmpTexBNoise    = bsxfun(@rdivide,tmpTexBNoise,  sqrt(sum(tmpTexBNoise(:).^2)));
    tmpZeroANoise   = bsxfun(@rdivide,tmpZeroANoise,  sqrt(sum(tmpZeroANoise(:).^2)));
elseif inParams.paramNorm == 4 % none
end

outR            = [tmpTexANoise(:); tmpTexBNoise(:); tmpZeroANoise(:)];

if ~inParams.scaleNoise
    tmpTexANoise    = tmpTexANoise + inParams.midN*randn(size(respA1));
    tmpTexBNoise    = tmpTexBNoise + inParams.midN*randn(size(respA1));
    tmpZeroANoise   = tmpZeroANoise + inParams.midN*randn(size(respA1));
else
    tmpTexANoise    = tmpTexANoise + (inParams.midN*randn(size(respA1))).*abs(tmpTexANoise);
    tmpTexBNoise    = tmpTexBNoise + (inParams.midN*randn(size(respA1))).*abs(tmpTexBNoise);
    tmpZeroANoise   = tmpZeroANoise + (inParams.midN*randn(size(respA1))).*abs(tmpZeroANoise);
end


if ~inParams.singlePool
    signalParams    = sqrt(sum(vec((tmpTexANoise  - tmpTexBNoise).^2)));
    noiseParams     = sqrt(sum(vec((tmpTexANoise  - tmpZeroANoise).^2)));
else
    mInd    = inParams.singlePool;
    
    signalParams    = sqrt(sum(vec((tmpTexANoise(:,mInd)  - tmpTexBNoise(:,mInd)).^2)));
    noiseParams     = sqrt(sum(vec((tmpTexANoise(:,mInd)  - tmpZeroANoise(:,mInd)).^2)));
end


outN            = noiseParams;
outS            = signalParams;

end




