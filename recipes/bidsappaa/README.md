
----------------------------------
## bidsappaa/toolVersion ##
BIDS App containing an instance of the Automatic Analysis.

Automatic Analysis software was originally developed by Dr Rhodri Cusack for supporting research at the MRC Cognition and Brain Science Unit. It is made available to the academic community in the hope that it may prove useful.

Definitions: aa means the Automatic Analysis software package and any associated documentation whether electronic or printed.

aa is a pipeline system for neuroimaging written primarily in Matlab. It robustly supports recent versions of SPM, as well as selected functions from other software packages. The goal is to facilitate automatic, flexible, and replicable neuroimaging analyses through a comprehensive pipeline system.

Example:
```
run <bids_dir> <output_dir> {participant|group}
           [--participant_label <participant_label>]
           [--freesurfer_license <license_file>]
           [--connection <pipeline to connect to>]
           [<tasklist> <user_customisation>]
```

More documentation can be found here: http://www.automaticanalysis.org/

To make the executables and scripts inside this container transparently available in the command line of environments where Neurocommand is installed (without the need to use 'Apptainer exec'): ml bidsappaa/toolVersion


For any papers that report data analyzed with aa, please include the website (http://www.automaticanalysis.org) and cite the aa paper:

Cusack R, Vicente-Grabovetsky A, Mitchell DJ, Wild CJ, Auer T, Linke AC, Peelle JE (2015) Automatic analysis (aa): Efficient neuroimaging workflows and parallel processing using Matlab and XML. Frontiers in Neuroinformatics 8:90.

----------------------------------

