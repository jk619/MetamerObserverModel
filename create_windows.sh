#!/bin/sh
#SBATCH --job-name=create_window
#SBATCH -a 0  # run this script as 2 jobs with SLURM_ARRAY_TASK_ID = 0 and 1. Add more numbers for more jobs!
#SBATCH --nodes=1 # nodes per job
#SBATCH --cpus-per-task=16 #~2 days to run PRFs
#SBATCH --mem=64gb # More memory you request the less priority you get
#SBATCH --time=50:00:00 # Max request to be safe...
#SBATCH --output=/scratch/jk7127/logs/create_windows_out_ses_%x-%a.txt # Define output log location
#SBATCH --error=/scratch/jk7127/logs/create_windows_err_ses_%x-%a.txt # and the error logs for when it inevitably crashes
#SBATCH --mail-user=jk7127@nyu.edu #email
#SBATCH --mail-type=END #email me when it crashes or better, ends


# To run this function write sbatch create_windows.sh 0.21 ; It only takes one argument which is the scaling of the window. So far we used [0.21 0.46 0.84]
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

