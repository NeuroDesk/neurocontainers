
----------------------------------
## romeo/3.2.4 ##
Unwrapping of 3D and 4D datasets. Coil combination of 5D datasets.



Example:
```
ROMEO is a command line application.

Example usage for single-echo or multiple time points with identical echo time (fMRI):
$ romeo ph.nii -m mag.ii -k nomask -o outputdir

Example usage for a 3-echo Scan with TE = [3,6,9] ms:
$ romeo ph.nii -m mag.ii -k nomask -t [3,6,9] -o outputdir

Note that echo times are required for unwrapping multi-echo data.
```

More documentation can be found here: https://github.com/korbinian90/ROMEO