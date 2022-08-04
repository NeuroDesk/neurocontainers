# test FastSurfer
cd /opt/FastSurfer/
wget https://files.au-1.osf.io/v1/resources/bt4ez/providers/osfstorage/5e9bf3ab430166067ea05564?action=download&direct&version=1
mv 5e9bf3ab430166067ea05564\?action\=download test.nii.gz
./run_fastsurfer.sh --t1 /opt/FastSurfer/test.nii.gz --sid test --seg_only