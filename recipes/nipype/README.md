
----------------------------------
## nipype/toolVersion ##
Python environment with VScode and singularity to run Nipype workflows

Setup:
```
# load required software (except spm, because SPM is build into the nipype container)
ml fsl/6.0.5.1
ml afni/22.1.14

# download test data
wget https://objectstorage.us-ashburn-1.oraclecloud.com/n/idrvm4tkz2a8/b/TOMCAT/o/TOMCAT_DIB/sub-01/ses-01_7T/anat/sub-01_ses-01_7T_T1w_defaced.nii.gz -O /neurodesktop-storage/sub-01_ses-01_7T_T1w_defaced.nii.gz 

gunzip /neurodesktop-storage/sub-01_ses-01_7T_T1w_defaced.nii.gz 

# start python
python
```

Python code:
```
import nipype.interfaces.spm as spm
from nipype.interfaces import fsl
from nipype.interfaces import afni

matlab_cmd = '/opt/spm12/run_spm12.sh /opt/mcr/v97/ script'
spm.SPMCommand.set_mlab_paths(matlab_cmd=matlab_cmd, use_mcr=True)

norm12 = spm.Normalize12()
norm12.inputs.image_to_align = '/neurodesktop-storage/sub-01_ses-01_7T_T1w_defaced.nii'
norm12.run()

btr = fsl.BET()
btr.inputs.in_file = '/neurodesktop-storage/sub-01_ses-01_7T_T1w_defaced.nii'
btr.inputs.frac = 0.4
btr.inputs.out_file = '/neurodesktop-storage/sub-01_ses-01_7T_T1w_defaced_brain.nii'
res = btr.run() 

edge3 = afni.Edge3()
edge3.inputs.in_file = '/neurodesktop-storage/sub-01_ses-01_7T_T1w_defaced.nii'
edge3.inputs.out_file = '/neurodesktop-storage/sub-01_ses-01_7T_T1w_defaced_edges.nii'
edge3.inputs.datum = 'byte'
res = edge3.run()
```

You can also use VS code and a jupyter notebook session in their to perform your analysis. Just type `code` in the terminal and enjoy :)




More documentation can be found here: https://nipype.readthedocs.io/en/latest/

To run applications outside of this container: ml nipype/toolVersion

----------------------------------
