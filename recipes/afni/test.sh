afni_system_check.py -check_all

#Test freesurfer functions
cp /opt/freesurfer-7.3.2/subjects/bert ~/bert -r

\@SUMA_Make_Spec_FS -NIFTI -fspath ~/bert/surf/ -sid bert

