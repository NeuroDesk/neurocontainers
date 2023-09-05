
----------------------------------
## bidstools/toolVersion ##
Contains a collection of tools useful for DICOM to BIDS conversion

Tools included:
```
dcm2niix: v1.0.20230411 https://github.com/rordenlab/dcm2niix
bidsmapper: https://bidscoin.readthedocs.io/en/latest/workflow.html#step-1a-running-the-bidsmapper
bidseditor: https://bidscoin.readthedocs.io/en/latest/workflow.html#step-1b-running-the-bidseditor
bidscoiner: https://bidscoin.readthedocs.io/en/latest/workflow.html#step-2-running-the-bidscoiner
rawmapper: https://bidscoin.readthedocs.io/en/latest/installation.html
deface: https://bidscoin.readthedocs.io/en/stable/bidsapps.html?highlight=deface#defacing
bidsparticipants: https://bidscoin.readthedocs.io/en/latest/installation.html
dicomsort: https://bidscoin.readthedocs.io/en/latest/installation.html
dcmtk: https://support.dcmtk.org/docs/pages.html
    dcmdump
    dump2dcm
    dcmconv
    dcm2json
    dcmodify
    img2dcm
    dcm2pnm
    dcmicmp
xmedcon: https://xmedcon.sourceforge.io/
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
