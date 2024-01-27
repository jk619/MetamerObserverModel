
curl -O -J -L https://osf.io/ytmvq/download
gunzip metamers_energy_met.tar.gz
tar -xvf metamers_energy_met.tar

curl -O -J -L https://osf.io/c4gaw/download
gunzip metamers_energy_ref.tar.gz
tar -xvf metamers_energy_ref.tar

mkdir metamers
mv metamers_energy_met ./metamers/
mv metamers_energy_ref ./metamers/

rm metamers_energy_ref.tar
rm metamers_energy_met.tar

curl -O -J -L https://osf.io/hv437/download
gunzip target_images.tar.gz
tar -xvf target_images.tar --one-top-level

rm target_images.tar


# create log directory under scratch
mkdir /scratch/$(whoami)/logs
