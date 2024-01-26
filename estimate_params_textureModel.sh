#!/bin/sh
#SBATCH --job-name=parameter_estimation_nat
#SBATCH -a 0-19  # run this script as 2 jobs with SLURM_ARRAY_TASK_ID = 0 and 1. Add more numbers for more jobs!
#SBATCH --nodes=1 # nodes per job
#SBATCH --cpus-per-task=16 #~2 days to run PRFs
#SBATCH --mem=32gb # More memory you request the less priority you get
#SBATCH --time=50:00:00 # Max request to be safe...
#SBATCH --output=/scratch/jk7127/logs/param_est_out_ses_%x-%a.txt # Define output log location
#SBATCH --error=/scratch/jk7127/logs/param_est_err_ses_%x-%a.txt # and the error logs for when it inevitably crashes
#SBATCH --mail-user=jk7127@nyu.edu #email
#SBATCH --mail-type=END #email me when it crashes or better, ends

#all_subjects=(ALESPA ANDBAS ANDTOR ANTBRA ARIZER ASISOR CALCAR CAMCAP CHISOL CHITOR CLALAV CLANUT DANDAC ELECHE EMAMAM FABGUA GIOTRI IVAPI MIRACQ NOVNAR PAOCON PIEAMB SARCOP TOMBIA VERTUL)
all_subjects=(azulejos bike boats gnarled graffiti grooming highway ivy leaves lettuce llama nyc palm portrait quad rocks terraces tiles treetop troop)
#all_subjects=(highway)
#all_subjects=(boats gnarled highway llama rocks)

module load matlab/2020b

# this variable tells us the job number:
jobnum=$SLURM_ARRAY_TASK_ID
if [ $jobnum -ge ${#all_subjects[@]} ]
then echo "Invalid subject id: $jobnum"
     exit 1
fi
sub=${all_subjects[$jobnum]}
wscale=$1;
echo $sub
# startup matlab...
matlab -nodesktop -nodisplay -nosplash <<EOF

clc
clear

mainPath    = '/scratch/jk7127/opposingEffects/'
windowPath  = fullfile(mainPath,'windows');
metPath    = fullfile(mainPath,'metamers');
myimage    = '$sub';

sprintf('%s',myimage')

met_types = {'metamers_energy_ref';'metamers_energy_met'};
%met_types = {'metamers_luminance_met';'metamers_luminance_ref'};

model     = 'energy';

addpath(genpath(mainPath));

w.scaling   = str2num('$wscale');
w.aspect    = 2;
w.size      = 2048;

%% load windows

%load(sprintf('%s/window_2048x2048_s=%.2f_a=%i.mat',windowPath,w.scaling,w.aspect))

%%

for mer = 1 : length(met_types)

    scalings = dir(sprintf('%s/%s/%s_model/%s/',metPath,met_types{mer},model,myimage));
    scalings = {scalings([scalings.isdir]).name};
    scalings = scalings(~ismember(scalings ,{'.','..','.DS_store'}));

    for s = 1 : length(scalings)

	
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


EOF

exit 0
