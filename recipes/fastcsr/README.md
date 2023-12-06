
----------------------------------
## fastcsr/1.0 ##
 Reconstructing cortical surfaces from structural magnetic resonance imaging (MRI) is a prerequisite for surface-based functional and anatomical image analyses. Conventional algorithms for cortical surface construction are computationally inefficient and typically take several hours for each subject, causing a bottleneck in applications when fast turnaround time is needed. To address this challenge, here we proposed a fast cortical surface reconstruction (FastCSR) pipeline based on deep machine learning. 

Example:
```
python3 pipeline.py --sd ./data --sid sub-001  --t1 ./data/sub-001.nii.gz
```

More documentation can be found here:  https://github.com/IndiLab/FastCSR/blob/main/README.md

To make the executables and scripts inside this container transparently available in the command line of environments where Neurocommand is installed: ml fastcsr/1.0

Citation:
```
https://github.com/IndiLab/FastCSR/tree/main
```

----------------------------------
