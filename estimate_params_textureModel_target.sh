#!/bin/sh
#SBATCH --job-name=parameter_estimation_target
#SBATCH -a 0-19  # run this script as 2 jobs with SLURM_ARRAY_TASK_ID = 0 and 1. Add more numbers for more jobs!
#SBATCH --nodes=1 # nodes per job
#SBATCH --cpus-per-task=16 #~2 days to run PRFs
#SBATCH --mem=128gb # More memory you request the less priority you get
#SBATCH --time=50:00:00 # Max request to be safe...
#SBATCH --output=/scratch/jaw288/logs/param_tar_est_out_ses_%x-%a.txt # Define output log location
#SBATCH --error=/scratch/jaw288/logs/param_tar_est_err_ses_%x-%a.txt # and the error logs for when it inevitably crashes
#SBATCH --mail-user=jaw288@nyu.edu #email
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
mainPath    = fullfile(fileparts(mfilename('fullpath')), '..');
windowPath    = fullfile(mainPath,'windows');
targetPath    = fullfile(mainPath,'target_images');
myimage    = '$sub';

addpath(genpath(mainPath));

w.scalings   = [0.21 0.46 0.84];
w.aspect    = 2;
w.size      = 2048;

%% load windows
%%

for s = 1 : length(w.scalings)
    
    w.scaling = w.scalings(s)
    load(sprintf('%s/window_2048x2048_s=%.2f_a=%i.mat',windowPath,w.scaling,w.aspect))

    oim = double((imread([targetPath filesep myimage '.png'])));
    sz = size(oim);
    mysize_pow_two =  log2(w.size);
    cropx = (sz(1)-2^mysize_pow_two) / 2;
    cropy = (sz(2)-2^mysize_pow_two) / 2;
    oim = oim(cropx+1:sz(1)-cropx,cropy+1:sz(2)-cropy,:);

            params 		= metamerAnalysis(oim,m,opts);
            [Out, ~]            = collectParams(params,opts);
            [mask, maskInds]    = collectParamMask(opts,params); % Get parameter mask
            [Out_masked]        = Out(mask,:); % Mask out duplicate parameters
    
    
	save(sprintf('%s/params_%s_s=%.2f_a=%i.mat',targetPath,myimage,w.scaling,w.aspect),'Out_masked');
%     
    
end

    
    
    
    
    



EOF

exit 0


