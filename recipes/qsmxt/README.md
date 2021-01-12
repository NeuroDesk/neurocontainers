

+++++++++++++++++++++ qsmxt/1.0.0 +++++++++++++++++++++++++
Quantitative susceptibility mapping allows the determination magnetic susceptibility from MRI phase data. QSMxT is a complete QSM pipeline from dicoms to final susceptibility maps.


Convert Dicom data to BIDS:
```
cd REPLACE_WITH_YOUR_DATA_DIRECTORY
python3 /opt/QSMxT/run_0_dicomSort.py REPLACE_WITH_YOUR_DICOM_INPUT_DATA_DIRECTORY dicom
python3 /opt/QSMxT/run_1_dicomToBids.py dicom bids
```
Run QSM pipeline:
```
python3 /opt/QSMxT/run_2_nipype_qsm.py bids qsm_output
```
Segment data (T1 and GRE) (UNDER CONSTRUCTION):
```
python3 /opt/QSMxT/run_3_nipype_segment.py bids segmentation_output
```
Build GRE group template (UNDER CONSTRUCTION):
```
python3 /opt/QSMxT/run_4_magnitude_template.py bids gre_template_output
```
Build QSM group template (UNDER CONSTRUCTION):
```
python3 /opt/QSMxT/run_5_qsm_template.py qsm_output gre_template_output qsm_template_output
```

More documentation can be found here: https://github.com/QSMxT/QSMxT

To run container outside of this environment: ml qsmxt/1.0.0
+++++++++++++++++++++ qsmxt/1.0.0 +++++++++++++++++++++++++

