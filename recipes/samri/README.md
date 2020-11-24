

+++++++++++++++++++++ samri +++++++++++++++++++++++++
samri standalone with Matlab Compiler Runtime

Example:
```
SAMRI

SAMRI bru2bids -o . -f '{"acquisition":["EPI"]}' -s '{"acquisition":["TurboRARE"]}' samri_bindata

SAMRI diagnose bids

SAMRI generic-prep -m '/usr/share/mouse-brain-atlases/dsurqec_200micron_mask.nii' -f '{"acquisition":["EPIlowcov"]}' -s '{"acquisition":["TurboRARElowcov"]}' bids '/usr/share/mouse-brain-atlases/dsurqec_200micron.nii'
```

More documentation can be found here: https://github.com/IBT-FMI/SAMRI

To run container outside of this environment: ml samri/0.5
+++++++++++++++++++++ samri +++++++++++++++++++++++++

