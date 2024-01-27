#!/bin/sh
#SBATCH --job-name=create_window
#SBATCH -a 0  # run this script as 2 jobs with SLURM_ARRAY_TASK_ID = 0 and 1. Add more numbers for more jobs!
#SBATCH --nodes=1 # nodes per job
#SBATCH --cpus-per-task=16 #~2 days to run PRFs
#SBATCH --mem=64gb # More memory you request the less priority you get
#SBATCH --time=50:00:00 # Max request to be safe...
#SBATCH --output=/scratch/jaw288/logs/create_windows_out_ses-%a.txt # Define output log location
#SBATCH --error=/scratch/jaw288/logs/create_windows_err_ses-%a.txt # and the error logs for when it inevitably crashes
#SBATCH --mail-user=jaw288@nyu.edu #email
#SBATCH --mail-type=END #email me when it crashes or better, ends

# example run sbatch create_windows.sh 0.84, the only argument [0.84] is scalng of analysis window


module load matlab/2020b
wscale=$1;
# startup matlab...
matlab -nodesktop -nodisplay -nosplash <<EOF

clc
clear

[~,whoami] = system('whoami'); whoami = whoami(1:end-1)

mainPath    = sprintf('/scratch/%s/MetamerObserverModel/',whoami)
windowPath  = fullfile(mainPath,'windows');
codePath    = fullfile(mainPath,'functions');
addpath(genpath(codePath));

w.scaling   = str2num('$wscale');
imSizes       = 2048;
aspect        = 2;
mkdir(windowPath)
opts = metamerOpts(rand(imSizes ,imSizes ),'windowType=radial',sprintf('scale=%.2f',w.scaling),sprintf('aspect=%i',aspect),'Nsc=4','Nor=4');
m = mkImMasks(opts);
filename = sprintf('window_%ix%i_s=%.2f_a=%i.mat',imSizes,imSizes,w.scaling,aspect);
save(sprintf('%s/%s',windowPath,filename),'m','opts','-v7.3');


disp('Complete!');


EOF

exit 0

