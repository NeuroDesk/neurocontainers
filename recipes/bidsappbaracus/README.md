
----------------------------------
## bidsappaa/1.1.4 ##
This BIDS App predicts brain age, based on data from Freesurfer 5.3. It combines data from cortical thickness, cortical surface area, and subcortical information (see Liem et al., 2017).

Example:
```
run_brain_age_bids.py [-h]
                             [--participant_label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...]]
                             [--freesurfer_dir FREESURFER_DIR]
                             [--models {Liem2016__OCI_norm,Liem2016__full_2samp_training} [{Liem2016__OCI_norm,Liem2016__full_2samp_training} ...]]
                             --license_key LICENSE_KEY [--n_cpus N_CPUS] [-v]
                             bids_dir out_dir {participant,group}
```

More documentation can be found here: https://github.com/bids-apps/baracus

To make the executables and scripts inside this container transparently available in the command line of environments where Neurocommand is installed (without the need to use 'Apptainer exec'): ml bidsappaa/1.1.4


If you use BARACUS in your work please cite:

Liem et al. (2017). Predicting brain-age from multimodal imaging data captures cognitive impairment. Neuroimage, 148:179–188, doi: 10.1016/j.neuroimage.2016.11.005.
the zenodo DOI of the BARACUS version you used, and
The FreeSurfer tool

----------------------------------

