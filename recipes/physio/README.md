
----------------------------------
## physio/R2021a ##
SPM12+PhysIO toolbox standalone with Matlab (R2021a) Compiler Runtime (v9.11)

Example:
- To run PhysIO batch file (`.m` or `.mat`) directly
  ```
  run_spm12.sh /opt/mcr/v911/ batch batch_spm_job.mat
  ```
- To call SPM for fMRI GUI
  ```
  run_spm12.sh /opt/mcr/v911/ fmri
  ```

The PhysIO Toolbox implements ideas for robust physiological noise modeling in fMRI, outlined in this paper:

1. Kasper, L., Bollmann, S., Diaconescu, A.O., Hutton, C., Heinzle, J., Iglesias, 
S., Hauser, T.U., Sebold, M., Manjaly, Z.-M., Pruessmann, K.P., Stephan, K.E., 2017. 
*The PhysIO Toolbox for Modeling Physiological Noise in fMRI Data*. 
Journal of Neuroscience Methods 276, 56-72. https://doi.org/10.1016/j.jneumeth.2016.10.019

PhysIO is part of the open-source [TAPAS Software Package](https://translationalneuromodeling.github.io/tapas/) for Translational Neuromodeling and Computational Psychiatry, introduced in the following paper:

2. Frässle, S., Aponte, E.A., Bollmann, S., Brodersen, K.H., Do, C.T., Harrison, O.K., Harrison, S.J., Heinzle, J., Iglesias, S., Kasper, L., Lomakina, E.I., Mathys, C., Müller-Schrader, M., Pereira, I., Petzschner, F.H., Raman, S., Schöbi, D., Toussaint, B., Weber, L.A., Yao, Y., Stephan, K.E., 2021. *TAPAS: an open-source software package for Translational Neuromodeling and Computational Psychiatry*. Frontiers in Psychiatry 12, 857. https://doi.org/10.3389/fpsyt.2021.680811

Please cite these works if you use PhysIO and see the [FAQ](https://gitlab.ethz.ch/physio/physio-doc/-/wikis/FAQ#3-how-do-i-cite-physio) for details.

NeuroDesk offers the possibility of running PhysIO without installing Matlab or requiring a Matlab license. The functionality should be equivalent, though debugging and extending the toolbox, as well as unreleased development features, will only be available in the Matlab version of PhysIO, which is exlusively hosted on the [TAPAS GitHub](https://github.com/translationalneuromodeling/tapas).

More general info about PhysIO is found in its [NeuroDesk Tutorial](https://neurodesk.github.io/tutorials/functional_imaging/physio/) and the [README](https://github.com/translationalneuromodeling/tapas/tree/master/PhysIO#readme) on GitHub.


To run container outside of this environment: ml physio/R2021a

----------------------------------
