
----------------------------------
## qsmxt/1.1.11 ##
A full QSM processing pipeline from DICOM to segmentation to evaluation of results. 

Usage:

1. Convert DICOM data to BIDS:
    ```bash
    python3 /opt/QSMxT/run_0_dicomSort.py REPLACE_WITH_YOUR_DICOM_INPUT_DATA_DIRECTORY 00_dicom
    python3 /opt/QSMxT/run_1_dicomConvert.py 00_dicom 01_bids
    ```
Carefully read the output of the `run_1_dicomConvert.py` script to ensure data were correctly recognized and converted. You can also pass command line arguments to identify the runs, e.g. `python3 /opt/QSMxT/run_1_dicomConvert.py 00_dicom 01_bids --t2starw_series_patterns *gre* --t1w_series_patterns *mp2rage*`. If the data were acquired on a GE scanner the complex data needs to be corrected by applying an FFT shift, this can be done with `python /opt/QSMxT/run_1_fixGEphaseFFTshift.py 01_bids/sub*/ses*/anat/*.nii*` .

2. Run QSM pipeline:
    ```bash
    python3 /opt/QSMxT/run_2_qsm.py 01_bids 02_qsm_output
    ```
3. Segment data (T1 and GRE):
    ```bash
    python3 /opt/QSMxT/run_3_segment.py 01_bids 03_segmentation
    ```
4. Build magnitude and QSM group template (only makes sense when you have more than about 30 participants):
    ```bash
    python3 /opt/QSMxT/run_4_template.py 01_bids 02_qsm_output 04_template
    ```
5. Export quantitative data to CSV using segmentations
    ```bash
    python3 /opt/QSMxT/run_5_analysis.py --labels_file /opt/QSMxT/aseg_labels.csv --segmentations 03_segmentation/qsm_segmentations/*.nii --qsm_files 02_qsm_output/qsm_final/*/*.nii --out_dir 06_analysis
    ```
6. Export quantitative data to CSV using a custom segmentation
    ```bash
    python3 /opt/QSMxT/run_5_analysis.py --segmentations my_segmentation.nii --qsm_files 04_qsm_template/qsm_transformed/*/*.nii --out_dir 07_analysis
    ```

## Common errors and workarounds
1. Return code: 137

If you run ` python3 /opt/QSMxT/run_2_qsm.py 01_bids 02_qsm_output` and you get this error:
```
Resampling phase data...
Killed
Return code: 137
``` 
This indicates insufficient memory for the pipeline to run. Check in your Docker settings if you provided sufficent RAM to your containers (e.g. a 0.75mm dataset requires around 20GB of memory)

2. RuntimeError: Insufficient resources available for job
This also indicates that there is not enough memory for the job to run. Try limiting the CPUs to about 6GB RAM per CPU. You can try inserting the option `--n_procs 1` into the commands to limit the processing to one thread, e.g.:
```bash
 python3 /opt/QSMxT/run_2_qsm.py 01_bids 02_qsm_output --n_procs 1
```

3. If you are getting the error "Insufficient memory to run QSMxT (xxx GB available; 6GB needed)
This means there is not enough memory available. Troulbeshoot advice when running this via Neurodesk is here: https://neurodesk.github.io/docs/neurodesktop/troubleshooting/#i-got-an-error-message-x-killed-or-not-enough-memory



More documentation can be found here: https://github.com/QSMxT/QSMxT

To run applications outside of this container: ml qsmxt/1.1.11

----------------------------------
