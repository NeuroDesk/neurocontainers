

+++++++++++++++++++++ tgvqsm/1.0.0 +++++++++++++++++++++++++
Quantitative susceptibility mapping allows the determination magnetic susceptibility from MRI phase data. TGV QSM is a python implementation to compute this.


Example:
```
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
+++++++++++++++++++++ tgvqsm/1.0.0 +++++++++++++++++++++++++

