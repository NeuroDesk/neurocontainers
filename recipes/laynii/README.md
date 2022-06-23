
----------------------------------
## LayNii/2.2.1 ##
LayNii is a standalone software suite for mesoscopic (functional) magnetic resonance imaging (e.g. layer-fMRI). 
It is a collection of C++ programs that depend only on a C++ compiler. 
The purpose of this package is to provide layer-analysis software that are not (yet) included in the other major MRI analysis software.

Example:
```
cp -r /opt/laynii-2.2.1/test_data/ ~
cd ~/test_data
LN2_LAYERS -rim sc_rim.nii -nr_layers 10 -equivol
LN2_LAYER_SMOOTH -input sc_VASO_act.nii -layer_file sc_layers.nii -FWHM 1
LN_BOCO -Nulled lo_Nulled_intemp.nii -BOLD lo_BOLD_intemp.nii
```

Tests:
```
cp -r /opt/laynii-2.2.1/test_data/ ~
cd ~/test_data
./tests.sh
```

More documentation can be found here: https://github.com/layerfMRI/LAYNII 
Algorithm explanations can be found here: https://thingsonthings.org/
and here: https://layerfmri.com/category/laynii/
Video tutorials of how to use LayNii are avaliable here: https://youtube.com/playlist?list=PLs_umVHtShfadNm8brOweXHUSmqVDTk4q

To run applications outside of this container: ml laynii/2.2.1

Citation:
```
Huber, L., Poser, B. A., Bandettini, P. A., Arora, K., Wagstyl, K., Cho, S., Goense, J., Nothnagel, N., Morgan, A. T., van den Hurk, J., Mueller A. K., Reynolds, R. C., Glen, D. R., Goebel, R. W., Gulban, O. F. (2021). LayNii: A software suite for layer-fMRI. NeuroImage, 118091. https://doi.org/10.1016/j.neuroimage.2021.118091
```

----------------------------------
