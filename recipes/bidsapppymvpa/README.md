
----------------------------------
## bidsapppymvpa/toolVersion ##
This pipeline takes fMRI data and generates ROI-based & searchlight MultiVariate Pattern Analysis (MVPA) results (including visualized patterns), and also runs Representational Similarity Analysis (RSA) using functionality from PyMVPA. Before running PyMVPA BIDS-App, data needs to be pre-processed using fMRIPrep.

Example:
```
run.py [-h] [-p PARTICIPANT_ID [PARTICIPANT_ID ...]] [-s SESSION]
              [--searchlight [SEARCHLIGHT]] [-t TASK]
              [-c CONDITIONS_TO_CLASSIFY [CONDITIONS_TO_CLASSIFY ...]]
              [--noinfolabel [NOINFOLABEL]] [--poly_detrend [POLY_DETREND]]
              [--tzscore] [--bzscore] [-i] [-f FEATURE_SELECT]
              [--cvtype CVTYPE] [--lss] [--rsa] [--surf]
              [--space [{fsnative,fsaverage}]] [--hemi [{l,r}]] [--mask MASK]
              [--dist [{correlation,euclidean,mahalanobis}]] [--nproc [NPROC]]
              [--skip_bids_validator] [-v]
              bids_dir output_dir {participant_prep,participant_test}
```

More documentation can be found here: https://github.com/bids-apps/PyMVPA

To make the executables and scripts inside this container transparently available in the command line of environments where Neurocommand is installed: ml bidsapppymvpa/toolVersion

----------------------------------

