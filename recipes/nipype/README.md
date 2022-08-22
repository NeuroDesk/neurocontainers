
----------------------------------
## nipype/1.8.3 ##
Python environment with VScode and singularity to run Nipype workflows

Setup:
```
# load required software (except spm, because it is currently build into the nipype container)
ml fsl/6.0.3
ml afni/
osf -p bt4ez fetch TOMCAT_DIB/sub-01/ses-01_7T/anat/sub-01_ses-01_7T_T1w_defaced.nii.gz /neurodesktop-storage/sub-01_ses-01_7T_T1w_defaced.nii.gz
gunzip /neurodesktop-storage/sub-01_ses-01_7T_T1w_defaced.nii.gz 

python
```

Python code:
```
import nipype.interfaces.spm as spm

matlab_cmd = '/opt/spm12/run_spm12.sh /opt/mcr/v97/ script'
spm.SPMCommand.set_mlab_paths(matlab_cmd=matlab_cmd, use_mcr=True)

norm12 = spm.Normalize12()
norm12.inputs.image_to_align = '/neurodesktop-storage/sub-01_ses-01_7T_T1w_defaced.nii'
norm12.inputs.image_to_align = '/home/neuro/sub-01_ses-01_7T_T1w_defaced.nii'
norm12.run()
```

More documentation can be found here: https://nipype.readthedocs.io/en/latest/

To run applications outside of this container: ml nipype/1.8.3

----------------------------------
