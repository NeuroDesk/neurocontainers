
----------------------------------
## cat12/r1904 ##
SPM12 standalone with CAT12 toolbox in Matlab Compiler Runtime

Example:
```
run_spm12.sh /opt/mcr/v93/
```

Example with nipype:
```
pip install pip install osfclient

osf -p bt4ez fetch TOMCAT_DIB/sub-01/ses-01_7T/anat/sub-01_ses-01_7T_T1w_defaced.nii.gz /neurodesktop-storage/sub-01_ses-01_7T_T1w_defaced.nii.gz

gunzip /neurodesktop-storage/sub-01_ses-01_7T_T1w_defaced.nii.gz

python
```

in python run:
```
import nipype.interfaces.spm as spm

matlab_cmd = '/opt/cat12/run_spm12.sh /opt/mcr/v93/ script'
spm.SPMCommand.set_mlab_paths(matlab_cmd=matlab_cmd, use_mcr=True)

norm12 = spm.Normalize12()
norm12.inputs.image_to_align = '/neurodesktop-storage/sub-01_ses-01_7T_T1w_defaced.nii'
norm12.run()

<!-- This throughs the error: Undefined function or variable 'mysubs_fields'. -->

path_mr = 'structural.nii'
cat = CAT12Segment(in_files=path_mr)
cat.run() 
```

More documentation can be found here: http://141.35.69.218/cat12/CAT12-Manual.pdf

To run container outside of this environment: ml cat12/r1904

----------------------------------
