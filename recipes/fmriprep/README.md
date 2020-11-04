fMRIPrep is a functional magnetic resonance imaging (fMRI) data preprocessing pipeline that is designed to provide an easily accessible, state-of-the-art interface that is robust to variations in scan acquisition protocols and that requires minimal user input, while providing easily interpretable and comprehensive error and output reporting. It performs basic processing steps (coregistration, normalization, unwarping, noise component extraction, segmentation, skullstripping etc.) providing outputs that can be easily submitted to a variety of group level analyses, including task-based or resting-state fMRI, graph theory measures, surface or volume-based statistics, etc.

example for running:
```
unset PYTHONPATH; singularity run fmriprep.simg \
  /work/04168/asdf/lonestar/ $WORK/lonestar/output \
  participant \
  --participant-label 387 --nthreads 16 -w $WORK/lonestar/work \
  --omp-nthreads 16
```

More documentation can be found here: https://mriqc.readthedocs.io/en/stable/running.html

