# MetamerObserverModel

1. cd to your scratch folder on cluster
2. git clone git@github.com:jk619/MetamerObserverModel.git
3. cd MetamerObserverModel
4. sh download_data.sh
5. sbatch create_windows.sh 0.84
6. sbatch estimate_params_textureModel_target.sh 0.84
7. sbatch estimate_params_textureModel_synth.sh 0.84

