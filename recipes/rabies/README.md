
----------------------------------
## rabies/0.3.5 ##
Rodent Automated Bold Improvement of EPI Sequences. 

Example:
```
The following section describes the basic syntax to run RABIES with an example dataset available here http://doi.org/10.5281/zenodo.3937697

reprocess

rabies -p MultiProc preprocess test_dataset/ preprocess_outputs/ --TR 1.0s --no_STC

First, this will run the minimal preprocessing step on the test dataset and store outputs into preprocess_outputs/ folder. The option -p MultiProc specifies to run the pipeline in parallel according to available local threads.

confound_correction

rabies -p MultiProc confound_correction preprocess_outputs/ confound_correction_outputs/ --TR 1.0s --commonspace_bold --smoothing_filter 0.3 --conf_list WM_signal CSF_signal vascular_signal mot_6

Next, to conduct the modeling and regression of confounding sources, the confound_correction step can be run with custom options for denoising. In this case, we apply a highpass filtering at 0.01Hz, together with the voxelwise regression of the 6 rigid realignment parameters and the mean WM,CSF and vascular signal which are derived from masks provided along with the anatomical template. Finally, a smoothing filter 0.3mm is applied. We are running this on the commonspace outputs from preprocess (--commonspace_bold), since we will run analysis in commonspace in the next step.

analysis

rabies -p MultiProc analysis confound_correction_outputs analysis_outputs/ --TR 1.0s --group_ICA --DR_ICA

Finally, RABIES has a few standard analysis options provided, which are specified in the Analysis documentation. In this example, we are going to run group independent component analysis (--group_ICA), using FSL's MELODIC function, followed by a dual regression (--DR_ICA) to back propagate the group components onto individual subjects.
```

More documentation can be found here: https://github.com/CoBrALab/RABIES

To run applications outside of this container: ml rabies/0.3.5

Citation:
```
Acknowledging RABIES: We currently ask users to acknowledge the usage of this software by citing the Github page https://github.com/CoBrALab/RABIES
```

----------------------------------
