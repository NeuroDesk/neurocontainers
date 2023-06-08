
----------------------------------
## spm12/toolVersion ##
SPM12 standalone with Matlab Compiler Runtime

Example:
```
run_spm12.sh /opt/mcr/v97/
```

Example with nipype:
```
pip install osfclient

osf -p bt4ez fetch TOMCAT_DIB/sub-01/ses-01_7T/anat/sub-01_ses-01_7T_T1w_defaced.nii.gz /neurodesktop-storage/sub-01_ses-01_7T_T1w_defaced.nii.gz

gunzip /neurodesktop-storage/sub-01_ses-01_7T_T1w_defaced.nii.gz 

python
```
```
import nipype.interfaces.spm as spm

matlab_cmd = '/opt/spm12/run_spm12.sh /opt/mcr/v97/ script'
spm.SPMCommand.set_mlab_paths(matlab_cmd=matlab_cmd, use_mcr=True)

norm12 = spm.Normalize12()
norm12.inputs.image_to_align = '/neurodesktop-storage/sub-01_ses-01_7T_T1w_defaced.nii'
norm12.run()
```

More documentation can be found here: https://www.fil.ion.ucl.ac.uk/spm/doc/

To run container outside of this environment: ml spm12/toolVersion

----------------------------------
