## xcpd/0.10.5 ##

XCP-D (eXtensible Connectivity Pipeline for DCAN-labs) aims to provide a robust and modular implementation of the most commonly used resting-state fMRI preprocessing steps. It adapts parts of the DCAN Labs processing pipeline to BIDS specifications and extends functionality of existing fMRI processing tools.

Example:
```
xcp_d -h
xcp_d /path/to/fmriprep_dir \
   /path/to/output_dir \
   participant \ # analysis_level
   --mode <mode> \ # required
   --participant-label <label> # optional
```


To run container outside of this environment: ml xcpd/0.10.5

More documentation can be found here: https://xcp-d.readthedocs.io/

Citation:
```
Mehta, K., Salo, T., Madison, T. J., Adebimpe, A., Bassett, D. S., Bertolero, M., ... & Satterthwaite, T. D. (2024). XCP-D: A Robust Pipeline for the post-processing of fMRI data. Imaging Neuroscience, 2, 1-26. doi:10.1162/imag_a_00257.
```

Please also cite the Zenodo DOI for the version you're referencing.

License: BSD 3-Clause License

License details: https://github.com/PennLINC/xcp_d/blob/main/LICENSE
