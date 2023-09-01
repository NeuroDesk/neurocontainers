
----------------------------------
## bidstools/toolVersion ##
Contains a collection of tools useful for DICOM to BIDS conversion

Tools included:
```
dcm2niix: https://github.com/rordenlab/dcm2niix
bidsmapper: https://bidscoin.readthedocs.io/en/latest/workflow.html#step-1a-running-the-bidsmapper
bidseditor: https://bidscoin.readthedocs.io/en/latest/workflow.html#step-1b-running-the-bidseditor
bidscoiner: https://bidscoin.readthedocs.io/en/latest/workflow.html#step-2-running-the-bidscoiner
bidsparticipants: https://bidscoin.readthedocs.io/en/latest/installation.html
bidstrainer: https://bidscoin.readthedocs.io/en/latest/installation.html
deface: 
dicomsort: https://bidscoin.readthedocs.io/en/latest/installation.html
pydeface: 
dcmtk: https://dcmtk.org/en/dcmtk/
xmedcon: https://xmedcon.sourceforge.io/
rawmapper: https://bidscoin.readthedocs.io/en/latest/installation.html
heudiconv: https://heudiconv.readthedocs.io/en/latest/heuristics.html
Bru2Nii: https://github.com/neurolabusc/Bru2Nii
```

Example converting dicom to BIDS using bidscoin: 
```
dicomsort dicomfolder/sub-folder -r -e .IMA
bidsmapper dicomfolder bidsoutputfolder
bidscoiner dicomfolder bidsoutputfolder
```

Example converting Bruker data to Nifti
```
Bru2 -o /Users/cr/dir2/out /Users/cr/dir/acqp
```

To run container outside of this environment: ml bidstools/toolVersion

----------------------------------
