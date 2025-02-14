## hcpasl/1.0.0 ##
HCP-ASL is a tool for processing ASL (Arterial Spin Labeling) data following the Human Connectome Project (HCP) minimal preprocessing pipelines. It provides a complete pipeline for processing ASL data, including motion correction, distortion correction, and calibration.

The tool requires FSL, FreeSurfer, Workbench and HCP Pipelines as dependencies which are all included in this container.

Example:
```
process_hcp_asl --help
process_hcp_asl --subid ${Subjectid} --subdir ${SubDir} --mbpcasl ${mbpcasl} --fmap_ap ${SEFM_AP} --fmap_pa ${SEFM_PA} --grads ${GradientCoeffs}
```

More documentation can be found here: https://github.com/physimals/hcp-asl

To run container outside of this environment: ml hcpasl/1.0.0

Citation:
```
If you use HCP-ASL in your research, please cite:
https://github.com/physimals/hcp-asl
```
