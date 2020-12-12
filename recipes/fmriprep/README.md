fMRIPrep is a functional magnetic resonance imaging (fMRI) data preprocessing pipeline that is designed to provide an easily accessible, state-of-the-art interface that is robust to variations in scan acquisition protocols and that requires minimal user input, while providing easily interpretable and comprehensive error and output reporting. It performs basic processing steps (coregistration, normalization, unwarping, noise component extraction, segmentation, skullstripping etc.) providing outputs that can be easily submitted to a variety of group level analyses, including task-based or resting-state fMRI, graph theory measures, surface or volume-based statistics, etc.

usage: 
```
fmriprep [-h] [--version] [--skip_bids_validation]
                [--participant-label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...]]
                [-t TASK_ID] [--echo-idx ECHO_IDX] [--bids-filter-file FILE]
                [--anat-derivatives PATH] [--bids-database-dir PATH]
                [--nprocs NPROCS] [--omp-nthreads OMP_NTHREADS]
                [--mem MEMORY_GB] [--low-mem] [--use-plugin FILE]
                [--anat-only] [--boilerplate_only] [--md-only-boilerplate]
                [--error-on-aroma-warnings] [-v]
                [--ignore {fieldmaps,slicetiming,sbref,t2w,flair} [{fieldmaps,slicetiming,sbref,t2w,flair} ...]]
                [--longitudinal]
                [--output-spaces [OUTPUT_SPACES [OUTPUT_SPACES ...]]]
                [--bold2t1w-init {register,header}] [--bold2t1w-dof {6,9,12}]
                [--force-bbr] [--force-no-bbr] [--medial-surface-nan]
                [--dummy-scans DUMMY_SCANS] [--random-seed _RANDOM_SEED]
                [--use-aroma]
                [--aroma-melodic-dimensionality AROMA_MELODIC_DIM]
                [--return-all-components]
                [--fd-spike-threshold REGRESSORS_FD_TH]
                [--dvars-spike-threshold REGRESSORS_DVARS_TH]
                [--skull-strip-template SKULL_STRIP_TEMPLATE]
                [--skull-strip-fixed-seed]
                [--skull-strip-t1w {auto,skip,force}] [--fmap-bspline]
                [--fmap-no-demean] [--use-syn-sdc] [--force-syn]
                [--fs-license-file FILE] [--fs-subjects-dir PATH]
                [--no-submm-recon] [--cifti-output [{91k,170k}] |
                --fs-no-reconall] [-w WORK_DIR] [--clean-workdir]
                [--resource-monitor] [--reports-only] [--config-file FILE]
                [--write-graph] [--stop-on-first-crash] [--notrack]
                [--debug {compcor,all} [{compcor,all} ...]] [--sloppy]
                bids_dir output_dir {participant}

example:
fmriprep replace_with_bidsdirectory replace_with_outputdirecotry participant --fs-license-file ~/.license.txt
```

More documentation can be found here: https://mriqc.readthedocs.io/en/stable/running.html

