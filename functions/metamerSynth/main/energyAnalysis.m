function params = energyAnalysis(oim,m,opts)

% computes statistical parameters of an image (using a spectra model)
% within a family of overlapping, tiling
% regions defined by windows
%
%
% oim: original image
% m: structure of window functions
% opts: structure of options
%
% params: model statistical parameters (nParam x windows)
%
% jan, created 09/27/23
% code based on metamerAnalysis.m


Nsc = opts.Nsc;
Nor = opts.Nor;


[pyr,pind] = buildSCFpyr(oim,Nsc,Nor-1);

myenergy = cell(4,1);

% 24 statitics as in Billy's
% add mean luminance at the end (for now skip - not sure how to norm)
for l = 1 : Nsc
    for b = 1:Nor
        band = spyrBand(pyr,pind,l,b);
        myenergy{l}(:,:,b) = real(band).^2 + imag(band).^2;
    end

    if l == 1
        myenergy{l}(:,:,end+1) = oim;
    end

end


%%
% params = zeros(Nsc,Nor,m.scale{1}.nMasks);

for s = 1 : Nsc
    oim = myenergy{s};

    for imask=1:m.scale{1}.nMasks


        thisMask = squeeze(m.scale{s}.maskMat(imask,:,:));
        thisMaskNAN = thisMask;
        thisMaskNAN(thisMaskNAN==0) = NaN;
        thisMaskNAN(thisMaskNAN>0) = 1;

        for b = 1 : Nor
            mean0 = wmean2(oim(:,:,b),thisMask);
            params.(sprintf('s%i_o%i',s-1,b-1))(imask) = mean0;
        end

        if s == 1
            params.(sprintf('lum'))(imask) = wmean2(oim(:,:,end),thisMask);
        end

    end

end

% params = reshape(params,[Nor*Nsc m.scale{1}.nMasks]);


end