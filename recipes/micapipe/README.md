
----------------------------------
## micapipe/toolVersion ##
Micapipe is a processing pipeline providing a robust framework to analyze multimodal MRI data. This pipeline integrates processing streams for T1-weighted, microstructure-sensitive, diffusion-weighted, and resting-state functional imaging to facilitate the development of multiscale models of neural organization. For this purpose, we leverage several specialized software packages to bring BIDS-formatted raw MRI data to fully-processed surface-based feature matrices.

Example:
```
micapipe -h
```

More documentation can be found here: (https://micapipe.readthedocs.io/en/latest/pages/01.whatyouneed/index.html)

To make the executables and scripts inside this container transparently available in the command line of environments where Neurocommand is installed: ml micapipe/toolVersion

Citation:
```

Raúl R. Cruces, Jessica Royer, Peer Herholz, Sara Larivière, Reinder Vos de Wael, Casey Paquola, Oualid Benkarim, Bo-yong Park, Janie Degré-Pelletier, Mark Nelson, Jordan DeKraker, Ilana Leppert, Christine Tardif, Jean-Baptiste Poline, Luis Concha, Boris C. Bernhardt. (2022). Micapipe: a pipeline for multimodal neuroimaging and connectome analysis. NeuroImage, 2022, 119612, ISSN 1053-8119. doi: https://doi.org/10.1016/j.neuroimage.2022.119612

```

License: 
Copyright 2022, micapipe Revision c403161d.

----------------------------------
