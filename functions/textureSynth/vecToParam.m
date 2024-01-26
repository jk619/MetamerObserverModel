function param = vecToParam(vec,inds,nsc,nori,na)

% param = vecToParam(vec,inds,nsc,nori,na)
%
% convert vector of texture parameters to a structure for use with
% textureSynthesis.m

nbands = nsc*nori + 2;

% pixelStats inds
% [mean var skew kurt mn mx];
param.pixelStats = reshape(vec(inds.pixelStats),1,6);

% pixelLPStats inds (nsc+1 x 2)
param.pixelLPStats = reshape(vec(inds.pixelLPStats),nsc+1,2);

% autoCorrReal (na x na x nsc+1)
param.autoCorrReal = reshape(vec(inds.autoCorrReal),na,na,nsc+1);

% autoCorrMag (na x na x nsc x nori)
param.autoCorrMag = reshape(vec(inds.autoCorrMag),na,na,nsc,nori);

% magMeans (nbands x 1)
param.magMeans = reshape(vec(inds.magMeans),nbands,1);

% cousinMagCorr (nori x nori x nsc + 1)
% except last matrix is all zeros
param.cousinMagCorr = reshape(vec(inds.cousinMagCorr),nori,nori,nsc);
param.cousinMagCorr(:,:,nsc+1) = zeros(nori,nori);

% parentMagCorr (nori x nori x nsc)
% except last matrix is all zeros
param.parentMagCorr = reshape(vec(inds.parentMagCorr),nori,nori,nsc-1);
param.parentMagCorr(:,:,nsc) = zeros(nori,nori);

% cousinRealCorr (2*nori x 2*nori x nsc + 1)
% but first nsc only have nori x nori nonzero
% and last has nori+1 x nori+1 nonzero
% break into two sets of indices
tmpCousinRealCorr1 = reshape(vec(inds.cousinRealCorr1),nori,nori,nsc);
tmpCousinRealCorr1(nori+1:nori*2,nori+1:nori*2,1:nsc) = 0;

tmpCousinRealCorr2 = reshape(vec(inds.cousinRealCorr2),nori+1,nori+1);
tmpCousinRealCorr2(nori+2:nori*2,nori+2:nori*2) = 0;

param.cousinRealCorr = tmpCousinRealCorr1;
param.cousinRealCorr(:,:,nsc+1) = tmpCousinRealCorr2;

% parentRealCorr (2*nori x 2*nori x nsc)
% except first 1:nsc-1 have nori x nori*2
% and nsc has nori x nori+1
tmpParentRealCorr1 = reshape(vec(inds.parentRealCorr1),nori,nori*2,nsc-1);
tmpParentRealCorr1(nori+1:2*nori,:,:) = 0;

tmpParentRealCorr2 = reshape(vec(inds.parentRealCorr2),nori,nori+1);
tmpParentRealCorr2(nori+1:2*nori,nori+2:2*nori) = 0;

param.parentRealCorr = tmpParentRealCorr1;
param.parentRealCorr(:,:,nsc) = tmpParentRealCorr2;

% varianceHPR
param.varianceHPR = vec(inds.varianceHPR);


