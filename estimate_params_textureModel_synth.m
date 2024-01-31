
clc
clear


mainPath    = fullfile(fileparts(mfilename('fullpath')));
windowPath  = fullfile(mainPath,'windows');
metPath     = fullfile(mainPath,'metamers');
codePath    = fullfile(mainPath,'functions');
addpath(genpath(codePath));


myimage     = 'llama';
met_types   = {'metamers_energy_ref';'metamers_energy_met'};
model       = 'energy';


w.scaling   = 0.84;
w.aspect    = 2;
w.size      = 2048;

%% load windows



for mer = 1% : length(met_types)
    
    scalings = dir(sprintf('%s/%s/%s_model/%s/',metPath,met_types{mer},model,myimage));
    scalings = {scalings([scalings.isdir]).name};
    scalings = scalings(~ismember(scalings ,{'.','..','.DS_store'}));
    
    for s = 1% : length(scalings)
        
        
        impath = sprintf('%s/%s/%s_model/%s/%s/',metPath,met_types{mer},model,myimage,scalings{s});
        images = dir(sprintf('%s/*.png',impath));
        
        
        for i = 1 : length(images)
            
            [filepath,name,ext] = fileparts(images(i).name);
            
            if ~exist(sprintf('%sparams_%s_s=%.2f_a=%i.mat',impath,name,w.scaling,w.aspect),'file')
                
                disp(sprintf('%sparams_%s_s=%.2f_a=%i.mat',impath,name,w.scaling,w.aspect))
                
                if ~exist('m','var')
                    load(sprintf('%s/window_2048x2048_s=%.2f_a=%i.mat',windowPath,w.scaling,w.aspect))
                end
                
                oim = double((imread([images(i).folder filesep images(i).name])));
                sz = size(oim);
                mysize_pow_two =  log2(w.size);
                cropx = (sz(1)-2^mysize_pow_two) / 2;
                cropy = (sz(2)-2^mysize_pow_two) / 2;
                oim = oim(cropx+1:sz(1)-cropx,cropy+1:sz(2)-cropy,:);
                
                params = metamerAnalysis(oim,m,opts);
                
                [Out, ~]            = collectParams(params,opts);
                [mask, maskInds]    = collectParamMask(opts,params); % Get parameter mask
                [Out_masked]        = Out(mask,:); % Mask out duplicate parameters
                
                
                save(sprintf('%sparams_%s_s=%.2f_a=%i.mat',impath,name,w.scaling,w.aspect),'Out_masked');
            else
                disp('done')
            end
        end
    end
end

disp('Complete!');



