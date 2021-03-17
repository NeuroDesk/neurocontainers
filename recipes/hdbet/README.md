

+++++++++++++++++++++ hdbet/1.0.0 +++++++++++++++++++++++++
HD-BET was developed with MRI-data from a large multicentric clinical trial in adult brain tumor patients acquired across 37 institutions in Europe and included a broad range of MR hardware and acquisition parameters, pathologies or treatment-induced tissue alterations. We used 2/3 of data for training and validation and 1/3 for testing. Moreover independent testing of HD-BET was performed in three public benchmark datasets (NFBS, LPBA40 and CC-359).
HD-BET was trained with precontrast T1-w, postcontrast T1-w, T2-w and FLAIR sequences. It can perform independent brain extraction on various different MRI sequences and is not restricted to precontrast T1-weighted (T1-w) sequences. Other MRI sequences may work as well (just give it a try!)
HD-BET was designed to be robust with respect to brain tumors, lesions and resection cavities as well as different MRI scanner hardware and acquisition parameters.
HD-BET outperformed five publicly available brain extraction algorithms (FSL BET, AFNI 3DSkullStrip, Brainsuite BSE, ROBEX and BEaST) across all datasets and yielded median improvements of +1.33 to +2.63 points for the DICE coefficient and -0.80 to -2.75 mm for the Hausdorff distance (Bonferroni-adjusted p<0.001).

Example:
```
example for one file:
hd-bet -i INPUT_FILENAME -device cpu -mode fast -tta 0

example for a complete directory:
hd-bet -i INPUT_FOLDER -o OUTPUT_FOLDER -device cpu -mode fast -tta 0

The options -mode fast and -tta 0 will disable test time data augmentation (speedup of 8x) and use only one model instead of an ensemble of five models for the prediction.
```

More documentation can be found here: https://github.com/MIC-DKFZ/HD-BET

To run container outside of this environment: ml hdbet/1.0.0
+++++++++++++++++++++ hdbet/1.0.0 +++++++++++++++++++++++++

