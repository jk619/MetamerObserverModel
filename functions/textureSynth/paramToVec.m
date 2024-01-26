function [vec inds] = paramToVec(param,nsc,nori,na)

% [vec inds] = paramToVec(param,nsc,nori,na)
%
% convert a structure of texture parameters from textureAnalysis.m into 
% a vector 

nbands = nsc*nori + 2;

% pixelStats inds
% [mean var skew kurt mn mx];
nPixelStats = 6;
inds.pixelStats = 1:nPixelStats;
vec(inds.pixelStats) = vector(param.pixelStats);
curInd = max(inds.pixelStats);

% pixelLPStats inds (nsc+1 x 2)
inds.pixelLPStats = curInd+1:curInd+(nsc+1)*2;
vec(inds.pixelLPStats) = vector(param.pixelLPStats);
curInd = max(inds.pixelLPStats);

% autoCorrReal (na x na x nsc+1)
inds.autoCorrReal = curInd+1:curInd+(na*na*(nsc+1));
vec(inds.autoCorrReal) = vector(param.autoCorrReal);
curInd = max(inds.autoCorrReal);

% autoCorrMag (na x na x nsc x nori)
inds.autoCorrMag = curInd+1:curInd+(na*na*nsc*nori);
vec(inds.autoCorrMag) = vector(param.autoCorrMag);
curInd = max(inds.autoCorrMag);

% magMeans (nbands x 1)
inds.magMeans = curInd+1:curInd+nbands;
vec(inds.magMeans) = vector(param.magMeans);
curInd = max(inds.magMeans);

% cousinMagCorr (nori x nori x nsc + 1)
% except last matrix is all zeros
inds.cousinMagCorr = curInd+1:curInd+(nori*nori*nsc);
tmp = param.cousinMagCorr(:,:,1:nsc);
vec(inds.cousinMagCorr) = vector(tmp);
curInd = max(inds.cousinMagCorr);

% parentMagCorr (nori x nori x nsc)
% except last matrix is all zeros
inds.parentMagCorr = curInd+1:curInd+(nori*nori*(nsc-1));
tmp = param.parentMagCorr(:,:,1:nsc-1);
vec(inds.parentMagCorr) = vector(tmp);
curInd = max(inds.parentMagCorr);

% cousinRealCorr (2*nori x 2*nori x nsc + 1)
% but first 1:nsc only have nori x nori nonzero
% and nsc+1 has nori+1 x nori+1 nonzero
% break into two sets of indices
inds.cousinRealCorr1 = curInd+1:curInd+(nori*nori*nsc);
tmp = param.cousinRealCorr(1:nori,1:nori,1:nsc);
vec(inds.cousinRealCorr1) = vector(tmp);
curInd = max(inds.cousinRealCorr1);

inds.cousinRealCorr2 = curInd+1:curInd+((nori+1)*(nori+1));
tmp = param.cousinRealCorr(1:nori+1,1:nori+1,nsc+1);
vec(inds.cousinRealCorr2) = vector(tmp);
curInd = max(inds.cousinRealCorr2);

% parentRealCorr (2*nori x 2*nori x nsc)
% except first 1:nsc-1 have nori x nori*2
% and nsc has nori x nori+1
inds.parentRealCorr1 = curInd+1:curInd+(nori*nori*2*(nsc-1));
tmp = param.parentRealCorr(1:nori,1:nori*2,1:nsc-1);
vec(inds.parentRealCorr1) = vector(tmp);
curInd = max(inds.parentRealCorr1);

inds.parentRealCorr2 = curInd+1:curInd+(nori*(nori+1));
tmp = param.parentRealCorr(1:nori,1:nori+1,nsc);
vec(inds.parentRealCorr2) = vector(tmp);
curInd = max(inds.parentRealCorr2);

% varianceHPR
inds.varianceHPR = curInd+1:curInd+1;
vec(inds.varianceHPR) = param.varianceHPR;




