
----------------------------------
## wftfi/1.0.0 ##
NB we have removed CUDA for the time being

Description
Example source code to perform water–fat total field inversion (wfTFI)
  quantitative susceptibility mapping (QSM)
Christof Boehm, Nico Sollmann, Jakob Meineke, Stefan Ruschke, Michael
  Dieckmeyer, Kilian Weiss, Claus Zimmer, Marcus R. Makowski, Thomas Baum &
  Dimitrios Karampinos, Preconditioned water-fat total field inversion:
  Application to spine quantitative susceptibility mapping (2022),
  https://doi.org/10.1002/mrm.28903
@article{https://doi.org/10.1002/mrm.28903,
  author = {Boehm, Christof and Sollmann, Nico and Meineke, Jakob and Ruschke, Stefan and Dieckmeyer, Michael and Weiss, Kilian and Zimmer, Claus and Makowski, Marcus R. and Baum, Thomas and Karampinos, Dimitrios C.},
  title = {Preconditioned water-fat total field inversion: Application to spine quantitative susceptibility mapping},
  journal = {Magnetic Resonance in Medicine},
  volume = {87},
  number = {1},
  pages = {417-430},
  keywords = {MEDI, osteoblastic, osteolytic, spine, QSM, TFI, vertebral metastases},
  doi = {https://doi.org/10.1002/mrm.28903},
  url = {https://onlinelibrary.wiley.com/doi/abs/10.1002/mrm.28903},
  eprint = {https://onlinelibrary.wiley.com/doi/pdf/10.1002/mrm.28903},
  year = {2022}
}

set up
We use anaconda to set up python virtual environments. The appended
  environment.yml can be used to automatically install all dependencies. When
  you want to use an NVIDIA GPU open the environment.yml in line 5 and change
  the cudatoolkit version to you locally installed CUDA driver version. If
  you don’t have a NVIDIA GPU remove line 7 with the cupy dependency.
  Afterwards run:
conda env create --name wfTFI --file environment.yml
conda activate wfTFI

run file and example data
in data/spineExample.pickle the data of an time-interleaved multi-echo
  gradient echo spine protocol with 6 echoes can be found. Inside also the water-,
  fat, field-, and R2* maps can be found, which were estimated using an
  hierarchical multi-resolution graph cut algorithm (publication, code).
  Look into runFile.py on how to use the algorithm with the example data.



More documentation can be found here: https://gitlab.com/christofboehm/wftfi

To run container outside of this environment: ml wftfi/1.0.0

----------------------------------
