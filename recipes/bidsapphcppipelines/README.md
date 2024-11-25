
----------------------------------
## bidsapphcppipelines/toolVersion ##
This a BIDS App wrapper for HCP Pipelines v4.3.0. Like every BIDS App it consists of a container that includes all of the dependencies and run script that parses a BIDS dataset. BIDS Apps run on Windows, Linux, Mac as well as HPCs/clusters.

Example:
```
run.py [-h]
              [--participant_label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...]]
              [--session_label SESSION_LABEL [SESSION_LABEL ...]]
              [--n_cpus N_CPUS]
              [--stages {PreFreeSurfer,FreeSurfer,PostFreeSurfer,fMRIVolume,fMRISurface} [{PreFreeSurfer,FreeSurfer,PostFreeSurfer,fMRIVolume,fMRISurface} ...]]
              [--coreg {MSMSulc,FS}] [--gdcoeffs GDCOEFFS] --license_key
              LICENSE_KEY [-v] [--anat_unwarpdir {x,y,z,-x,-y,-z}]
              [--skip_bids_validation]
              bids_dir output_dir {participant}
```

More documentation can be found here: https://github.com/bids-apps/HCPPipelines

To make the executables and scripts inside this container transparently available in the command line of environments where Neurocommand is installed (without the need to use 'Apptainer exec'): ml bidsapphcppipelines/toolVersion

Please cite Glasser et al. 2013 and Smith et al. 2013.

----------------------------------

