
----------------------------------
## bidsappbrainsuite/21a ##
The BrainSuite BIDS App provides a portable, streamlined method for applying BrainSuite workflows to process and analyze anatomical, diffusion, and functional MRI data. This release of BrainSuite BIDS-App is based on version 21a of BrainSuite. The BrainSuite BIDS-App implements three major BrainSuite pipelines for subject-level analysis, as well as corresponding group-level analysis functionality.

Example:
```
/BrainSuite/run.py [-h]
              [--stages {CSE,SVREG,BDP,BFP,QC,DASHBOARD,ALL} [{CSE,SVREG,BDP,BFP,QC,DASHBOARD,ALL} ...]]
              [--preprocspec PREPROCSPEC]
              [--participant_label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...]]
              [--skipBSE] [--atlas {BSA,BCI-DNI,USCBrain}] [--singleThread]
              [--TR TR] [--fmri_task_name FMRI_TASK_NAME [FMRI_TASK_NAME ...]]
              [--ignore_suffix IGNORE_SUFFIX] [--QCdir QCDIR]
              [--QCsubjList QCSUBJLIST] [--localWebserver] [--port PORT]
              [--bindLocalHostOnly] [--modelspec MODELSPEC]
              [--analysistype {STRUCT,FUNC,ALL}] [--rmarkdown RMARKDOWN]
              [--ignoreSubjectConsistency] [--bidsconfig [BIDSCONFIG]]
              [--cache CACHE] [--ncpus NCPUS] [--maxmem MAXMEM] [-v]
              bids_dir output_dir {participant,group}
```

More documentation can be found here: https://github.com/bids-apps/BrainSuite

To make the executables and scripts inside this container transparently available in the command line of environments where Neurocommand is installed: ml bidsappbrainsuite/21a

----------------------------------

