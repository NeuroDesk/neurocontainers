# Example for ASHS
```
curl -o sub-01_ses-01_7T_T1w_defaced.nii.gz "https://files.au-1.osf.io/v1/resources/bt4ez/providers/osfstorage/5e9bf3ab430166067ea05564?action=download&direct&version=1" 
curl -o sub-01_ses-01_7T_T2w_run-1_tse.nii.gz "https://files.au-1.osf.io/v1/resources/bt4ez/providers/osfstorage/5e9bf3d1430166067ba07bff?action=download&direct&version=1"

mkdir ashs_atlas_magdeburg_7t_20180416
curl -fsSL --retry 5 http://ashs.projects.nitrc.org/atlas_magdeburg/ashs_atlas_magdeburg_7t_20180416.tgz \
      | tar -xz -C ashs_atlas_magdeburg_7t_20180416 --strip-components 1 

mkdir myworkdir

$ASHS_ROOT/bin/ashs_main.sh -I subj001 -a ashs_atlas_magdeburg_7t_20180416 \
   -g sub-01_ses-01_7T_T1w_defaced.nii.gz -f sub-01_ses-01_7T_T2w_run-1_tse.nii.gz \
   -w myworkdir/subj001

```