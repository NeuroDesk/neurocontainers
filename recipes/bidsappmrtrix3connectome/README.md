
----------------------------------
## bidsappmrtrix3connectome/toolVersion ##
This BIDS App enables generation and subsequent group analysis of structural connectomes generated from diffusion MRI data. The analysis pipeline relies primarily on the MRtrix3 software package, and includes a number of state-of-the-art methods for image processing, tractography reconstruction, connectome generation and inter-subject connection density normalisation.

Example:
```
mrtrix3_connectome.py bids_dir output_dir analysis_level [ options ]
```

More documentation can be found here: https://github.com/bids-apps/MRtrix3_connectome

To make the executables and scripts inside this container transparently available in the command line of environments where Neurocommand is installed: ml bidsappmrtrix3connectome/toolVersion

----------------------------------

