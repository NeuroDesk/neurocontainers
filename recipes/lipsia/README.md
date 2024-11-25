
----------------------------------
## lipsia/toolVersion ##


Example:
```
*Onesample test at the 2nd level* (`vlisa_onesample`_). 
Example: the input is a set of contrast maps called "data_*.nii.gz"::

  vlisa_onesample -in data_*.nii.gz -mask mask.nii -out result.v
  vnifti -in result.v -out result.nii


*Twosample test at the 2nd level* (`vlisa_twosample`_). 
Example: input are two sets of contrast maps called "data1_*.nii.gz" and "data2_*.nii.gz"::

  vlisa_twosample -in1 data1_*.nii.gz -in2 data2_*.nii.gz -mask mask.nii -out result.v
  vnifti -in result.v -out result.nii


*Single subject test (1st level)* (`vlisa_prewhitening`_). 
Example: input are two runs acquired in the same session called "run1.nii.gz" and "run2.nii.gz".
Preprocessing should include a correction for baseline drifts!::


  vlisa_prewhitening -in run1.nii.gz run2.nii.gz -design des1.txt des2.txt -mask mask.nii -out result.v 
  vnifti -in result.v -out result.nii
```

More documentation can be found here:  https://github.com/lipsia-fmri/lipsia

To make the executables and scripts inside this container transparently available in the command line of environments where Neurocommand is installed: ml REPLACE_WITH_Name_of_Container/toolVersion

Citation:
```
Lohmann et al (2023) "Improving the reliability of fMRI-based predictions of intelligence via semi-blind machine learning", bioRxiv, https://doi.org/10.1101/2023.11.03.565485


```

License: BSD-3-Clause license 


----------------------------------
