# Test AFNI functions
afni_system_check.py -check_all

#Test freesurfer functions
cp /opt/freesurfer-7.3.2/subjects/bert ~/bert -r

\@SUMA_Make_Spec_FS -NIFTI -fspath ~/bert/surf/ -sid bert


# Test R
R 
install.packages("data.table")
library("data.table")

# Test 3dLMEr
tar xvzf test.tgz
bash run.LMEr.txt

# Test SUMA
The suma crashes were triggered by a quite specific action: after opening suma, go to View > Object controller, then when I clicked and dragged the slider to adjust the T-threshold it would crash.
