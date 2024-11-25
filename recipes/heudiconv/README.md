
----------------------------------
## heudiconv/1.3.1 ##
heudiconv is a flexible DICOM converter for organizing brain imaging data into structured directory layouts.

Example:
```
heudiconv  --files dicom/219/itbs/*/*.dcm -o Nifti -f Nifti/code/heuristic1.py -s 219 -ss itbs -c dcm2niix -b --minmeta --overwrite
```

More documentation can be found here: https://heudiconv.readthedocs.io/en/latest/quickstart.html

To make the executables and scripts inside this container transparently available in the command line of environments where Neurocommand is installed: ml heudiconv/1.3.1

Citation:
```
Halchenko, Yaroslav O., Mathias Goncalves, Satrajit Ghosh, Pablo Velasco, Matteo Visconti Di Oleggio Castello, Taylor Salo, John T. Wodder Ii, et al. “HeuDiConv — Flexible DICOM Conversion into Structureddirectory Layouts.” Journal of Open Source Software 9, no. 99 (July 3, 2024): 5839. https://doi.org/10.21105/joss.05839.
```

License: Apache License, Version 2.0

----------------------------------
