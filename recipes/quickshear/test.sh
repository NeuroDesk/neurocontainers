pip install osfclient
osf -p ru43c clone .
cd osfstorage
unzip 01_bids.zip
cd 01_bids/sub-170705134431std1312211075243167001/ses-1/anat
cp sub-170705134431std1312211075243167001_ses-1_run-1_part-mag_T2starw.nii input.nii
mri_synthstrip -i input.nii -o stripped.nii.gz -m mask.nii.gz 
quickshear input.nii mask.nii.gz defaced.nii.gz