
----------------------------------
## dafne/toolVersion ##
Dafne is a program for the segmentation of medical images, specifically MR images, that includes advanced deep learning models for an automatic segmentation. The user has the option of refining the automated results, and the software will learn from the improvements and modify its internal models accordingly. In order to continuously improve the performance, the deep learning modules are stored in a central server location.

Dafne uses incremental learning and federated learning to continuously adapt the models to the need of our users. This means that when you perform a segmentation, initially it will not be perfect. You will then have the chance to refine it. When you are satisfied with your dataset, you will export your ROI masks (see below). During this export procedure, the software automatically learns from your refined segmentation and sends the updated model back to our servers. This is why the export procedure takes some time. We will automatically integrate your updated model with the models of our other users, so you will always receive the most accurate predictor. You can also manually perform the incremental learning from the Tools menu (see below)

Example:
```
dafne
```

More documentation can be found here: https://dafne.network/documentation/

To make the executables and scripts inside this container transparently available in the command line of environments where Neurocommand is installed: ml dafne/toolVersion

Citation:
```
Santini F, Wasserthal J, Agosti A, et al. Deep Anatomical Federated Network (Dafne): an open client/server framework for the continuous collaborative improvement of deep-learning-based medical image segmentation. 2023 doi: 10.48550/arXiv.2302.06352.
```

License: GNU General Public License, https://dafne.network/documentation/#license

----------------------------------
