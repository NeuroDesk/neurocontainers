
----------------------------------
## neurodock/1.0.0 ##
PyD is an installable Python package deisgned to perform pre- and post- processing of dMRI acquisitions.

Example:
```
pydesigner -s --verbose \
~/Dataset/DKI_B0.nii,~/Dataset/DKI_B1000.nii,~/Dataset/DKI_B2000.nii
```

More documentation can be found here: https://pydesigner.readthedocs.io/en/latest/processing/running_pyd.html

To make the executables and scripts inside this container transparently available in the command line of environments where Neurocommand is installed: ml neurodock/1.0.0

Citation:
```
Siddhartha Dhiman, Joshua B Teves, Kathryn E Thorn, Emilie T McKinnon,
Hunter G Moss, Vitria Adisetiyo, Benjamin Ades-Aron, Jelle Veraart, Jenny Chen,
Els Fieremans, Andreana Benitez, Joseph A Helpern, Jens H Jensen. PyDesigner: A
Pythonic Implementation of the DESIGNER Pipeline for Diffusion Tensor and
Diffusional Kurtosis Imaging. bioRxiv 2021.10.20.465189. doi:
https://doi.org/10.1101/2021.10.20.465189```

License: Custom license non-commerical, non-clinical care: https://github.com/muscbridge/PyDesigner?tab=License-1-ov-file#readme

----------------------------------
