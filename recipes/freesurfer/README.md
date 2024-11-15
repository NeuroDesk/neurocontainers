
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

Citation:
```
Also see https://surfer.nmr.mgh.harvard.edu/fswiki/FreeSurferMethodsCitation

recon-all
Collins, DL, Neelin, P., Peters, TM, and Evans, AC. (1994) Automatic 3D Inter-Subject Registration of MR Volumetric Data in Standardized Talairach Space, Journal of Computer Assisted Tomography, 18(2) p192-205, 1994 PMID: 8126267; UI: 94172121

Cortical Surface-Based Analysis I: Segmentation and Surface Reconstruction Dale, A.M., Fischl, Bruce, Sereno, M.I., (1999). Cortical Surface-Based Analysis I: Segmentation and Surface Reconstruction. NeuroImage 9(2):179-194

Fischl, B.R., Sereno, M.I.,Dale, A. M. (1999) Cortical Surface-Based Analysis II: Inflation, Flattening, and Surface-Based Coordinate System. NeuroImage, 9, 195-207.

Fischl, Bruce, Sereno, M.I., Tootell, R.B.H., and Dale, A.M., (1999). High-resolution inter-subject averaging and a coordinate system for the cortical surface. Human Brain Mapping, 8(4): 272-284

Fischl, Bruce, and Dale, A.M., (2000). Measuring the Thickness of the Human Cerebral Cortex from Magnetic Resonance Images. Proceedings of the National Academy of Sciences, 97:11044-11049.

Fischl, Bruce, Liu, Arthur, and Dale, A.M., (2001). Automated Manifold Surgery: Constructing Geometrically Accurate and Topologically Correct Models of the Human Cerebral Cortex. IEEE Transactions on Medical Imaging, 20(1):70-80

Non-Uniform Intensity Correction. http://www.bic.mni.mcgill.ca/software/N3/node6.html

Fischl B, Salat DH, Busa E, Albert M, Dieterich M, Haselgrove C, van der Kouwe A, Killiany R, Kennedy D, Klaveness S, Montillo A, Makris N, Rosen B, Dale AM. Whole brain segmentation: automated labeling of neuroanatomical structures in the human brain. Neuron. 2002 Jan 31;33(3):341-55.

Bruce Fischl, Andre van der Kouwe, Christophe Destrieux, Eric Halgren, Florent Segonne, David H. Salat, Evelina Busa, Larry J. Seidman, Jill Goldstein, David Kennedy, Verne Caviness, Nikos Makris, Bruce Rosen, and Anders M. Dale. Automatically Parcellating the Human Cerebral Cortex. Cerebral Cortex January 2004; 14:11-22.

Brainstem
Bayesian segmentation of brainstem structures in MRI. Iglesias, J.E., Van Leemput, K., Bhatt, P., Casillas, C., Dutt, S., Schuff, N., Truran-Sacrey, D., Boxer, A., and Fischl, B. NeuroImage, 113, June 2015, 184-195.

Hippocampus and amygdala
Hippocampus: A computational atlas of the hippocampal formation using ex vivo, ultra-high resolution MRI: Application to adaptive segmentation of in vivo MRI. Iglesias, J.E., Augustinack, J.C., Nguyen, K., Player, C.M., Player, A., Wright, M., Roy, N., Frosch, M.P., Mc Kee, A.C., Wald, L.L., Fischl, B., and Van Leemput, K. Neuroimage, 115, July 2015, 117-137.

Amygdala: High-resolution magnetic resonance imaging reveals nuclei of the human amygdala: manual segmentation to automatic atlas. Saygin ZM & Kliemann D (joint 1st authors), Iglesias JE, van der Kouwe AJW, Boyd E, Reuter M, Stevens A, Van Leemput K, Mc Kee A, Frosch MP, Fischl B, Augustinack JC. Neuroimage, 155, July 2017, 370-382.

Longitudinal method: Bayesian longitudinal segmentation of hippocampal substructures in brain MRI using subject-specific atlases. Iglesias JE, Van Leemput K, Augustinack J, Insausti R, Fischl B, Reuter M. Neuroimage, 141, November 2016, 542-555.

"MM" hippocampal subregions
A reorganization of Freesurfer's segmentation into anterior and posterior segments as described in:

McHugo M, Talati P, Woodward ND, Armstrong K, Blackford JU, Heckers S. Regionally specific volume deficits along the hippocampal long axis in early and chronic psychosis. Neuroimage Clin. 2018;20:1106-1114. doi:10.1016/j.nicl.2018.10.021

Thalamus
A probabilistic atlas of the human thalamic nuclei combining ex vivo MRI and histology. Iglesias, J.E., Insausti, R., Lerma-Usabiaga, G., Bocchetta, M., Van Leemput, K., Greve, D., van der Kouwe, A., Caballero-Gaudes, C., Paz-Alonso, P. Neuroimage (accepted).
```

License: Custom License https://surfer.nmr.mgh.harvard.edu/fswiki/FreeSurferSoftwareLicense
----------------------------------
