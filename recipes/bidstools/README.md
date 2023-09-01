
----------------------------------
## bidstools/1.0.0 ##
Contains a collection of tools needed for DICOM to BIDS conversion

Example:
```
dcm2niix
bidsmapper
bidscoiner
bidseditor
bidsparticipants
bidstrainer
deface
dicomsort
pydeface
rawmapper
heudiconv:
For heudiconv usage, please refer to: https://heudiconv.readthedocs.io/en/latest/heuristics.html

convert dicom to bids:
dicomsort dicomfolder/sub-folder -r -e .IMA
bidsmapper dicomfolder bidsoutputfolder
bidscoiner dicomfolder bidsoutputfolder

also contains Bru2Nii: https://github.com/neurolabusc/Bru2Nii
Bru2 -o /Users/cr/dir2/out /Users/cr/dir/acqp
```

More documentation can be found here:
https://bidscoin.readthedocs.io/en/latest/installation.html
https://github.com/rordenlab/dcm2niix


To run container outside of this environment: ml bidstools/1.0.0

----------------------------------
