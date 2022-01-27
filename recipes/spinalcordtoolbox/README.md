
----------------------------------
## spinalcordtoolbox/5.5 ##
CT tools process MRI data (NIfTI files) and can do fully automatic tasks such as:
- Segmentation of the spinal cord and gray matter
- Segmentation of pathologies (eg. multiple sclerosis lesions)
- Detection of anatomical highlights (eg. ponto-medullary junction, spinal cord centerline, vertebral levels)
- Registration to template, and deformation (eg. straightening)
- Motion correction for diffusion and functional MRI time series

Computation of quantitative MRI metrics (eg. diffusion tensor imaging, magnetization transfer)
- Texture analysis (eg. grey level co-occurrence matrix)
- Extraction of metrics within anatomical regions (eg. white matter tracts)

SCT also has low-level tools:
- Help out with manual labeling and segmentation with a Graphical User Interface (GUI)
- GUI plugin for FSLeyes
- Warping field creation and application
- NIFTI volume manipulation tools for common operations

More documentation can be found here: https://spinalcordtoolbox.com/en/latest/user_section/getting-started.html

To run container outside of this environment: ml spinalcordtoolbox/5.5

----------------------------------

