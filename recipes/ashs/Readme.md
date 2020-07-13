# Example for ASHS
```
wget https://files.au-1.osf.io/v1/resources/bt4ez/providers/osfstorage/5e9bf3ab430166067ea05564?action=download&direct&version=1
wget https://files.au-1.osf.io/v1/resources/bt4ez/providers/osfstorage/5e9bf3d1430166067ba07bff?action=download&direct&version=1

mkdir myworkdir

$ASHS_ROOT/bin/ashs_main.sh -I subj001 -a /atlas_ashs_atlas_upennpmc_20161128
   -g sub-01_ses-01_7T_T1w_defaced.nii.gz -f sub-01_ses-01_7T_T2w_run-1_tse.nii.gz 
   -w myworkdir/subj001

```