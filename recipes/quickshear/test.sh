pip install osfclient
osf -p bt4ez fetch TOMCAT_DIB/sub-01/ses-01_7T/anat/sub-01_ses-01_7T_T1w_defaced.nii.gz sub-01_ses-01_7T_T1w_defaced.nii.gz
mv sub-01_ses-01_7T_T1w_defaced.nii.gz input.nii.gz
mri_synthstrip -i input.nii.gz -o stripped.nii.gz -m mask.nii.gz 
quickshear input.nii.gz mask.nii.gz defaced.nii.gz