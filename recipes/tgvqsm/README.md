
----------------------------------
## tgvqsm/1.0.0 ##
Quantitative susceptibility mapping allows the determination magnetic susceptibility from MRI phase data. TGV QSM is a python implementation to compute this.

This container also includes bet2 for brain extraction and dcm2niix to convert dicom data to NiFTI files.

Example:
```
dcm2niix -o ./ -f magnitude GR_M_5_QSM_p2_1mmIso_TE20/
dcm2niix -o ./ -f phase GR_P_6_QSM_p2_1mmIso_TE20/

bet2 magnitude.nii magnitude_bet2

tgv_qsm \
  -p phase.nii \
  -m magnitude_bet2_mask.nii.gz \
  -f 2.89 \
  -t 0.02 \
  -s \
  -o qsm
```

More documentation can be found here: http://www.neuroimaging.at/pages/qsm.php

To run container outside of this environment: ml tgvqsm/1.0.0

Citation:
```
Langkammer, C; Bredies, K; Poser, BA; Barth, M; Reishofer, G; Fan, AP; Bilgic, B; Fazekas, F; Mainero; C; Ropele, S
Fast Quantitative Susceptibility Mapping using 3D EPI and Total Generalized Variation.
Neuroimage. 2015 May 1;111:622-30. doi: 10.1016/j.neuroimage.2015.02.041
```

----------------------------------
