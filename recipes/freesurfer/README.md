
----------------------------------
## freesurfer/8.0.0 ##
FreeSurfer contains a set of programs with a common focus of analyzing magnetic resonance imaging scans of brain tissue. It is an important tool in functional brain mapping and contains tools to conduct both volume based and surface based analysis.

Example:
```
# start freesurfer from application menu or load freesurfer via module load command
mkdir /neurodesktop-storage/freesurfer_output
export SUBJECTS_DIR=/neurodesktop-storage/freesurfer_output
export SINGULARITYENV_SUBJECTS_DIR=$SUBJECTS_DIR
recon-all -subject subjectname -i invol1.nii.gz -all
```

More documentation can be found here: https://surfer.nmr.mgh.harvard.edu/fswiki/recon-all

To run container outside of this environment: ml freesurfer/8.0.0

Citation: see https://surfer.nmr.mgh.harvard.edu/fswiki/FreeSurferMethodsCitation

License: Custom License https://surfer.nmr.mgh.harvard.edu/fswiki/FreeSurferSoftwareLicense
----------------------------------
