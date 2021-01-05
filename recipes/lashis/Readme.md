

+++++++++++++++++++++ lashis/1.0 +++++++++++++++++++++++++
Longitudinal Automatic Segmentation of Hippocampal Subfields (LASHiS) using multi-contrast MRI.

The publication for this work is available at https://doi.org/10.1016/j.neuroimage.2020.116798

Data for the TOMCAT dataset referenced in this work is located at https://osf.io/bt4ez/

Example:
```
wget https://files.au-1.osf.io/v1/resources/bt4ez/providers/osfstorage/5e9bf3ab430166067ea05564?action=download&direct&version=1
wget https://files.au-1.osf.io/v1/resources/bt4ez/providers/osfstorage/5e9bf3d1430166067ba07bff?action=download&direct&version=1
wget https://files.au-1.osf.io/v1/resources/bt4ez/providers/osfstorage/5e9bf4eed69735065dbe02a0?action=download&direct&version=1
wget https://files.au-1.osf.io/v1/resources/bt4ez/providers/osfstorage/5e9bf4a04301660669a0fa44?action=download&direct&version=1

/LASHiS/LASHiS.sh -a /atlas_ashs_atlas_upennpmc_20161128 -o example_run sub-01_ses-01_7T_T1w_defaced.nii.gz sub-01_ses-01_7T_T2w_run-1_tse.nii.gz sub-01_ses-02_7T_T1w_defaced.nii.gz sub-01_ses-02_7T_T2w_run-1_tse.nii.gz
```

More documentation can be found here: https://github.com/thomshaw92/LASHiS

To run container outside of this environment: ml lashis/1.0
+++++++++++++++++++++ lashis/1.0 +++++++++++++++++++++++++

