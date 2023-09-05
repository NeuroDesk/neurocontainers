
----------------------------------
## bidstools/1.0.1 ##
Contains a collection of tools useful for DICOM to BIDS conversion

Tools included:
```
dcm2niix: v1.0.20230411 https://github.com/rordenlab/dcm2niix
bidsmapper: https://bidscoin.readthedocs.io/en/latest/workflow.html#step-1a-running-the-bidsmapper
bidseditor: https://bidscoin.readthedocs.io/en/latest/workflow.html#step-1b-running-the-bidseditor
bidscoiner: https://bidscoin.readthedocs.io/en/latest/workflow.html#step-2-running-the-bidscoiner
rawmapper: https://bidscoin.readthedocs.io/en/latest/installation.html
bidsparticipants: https://bidscoin.readthedocs.io/en/latest/installation.html
dicomsort: https://bidscoin.readthedocs.io/en/latest/installation.html
dcmtk: https://dcmtk.org/en/dcmtk/
    config   - configuration utilities for DCMTK
    dcmdata  - a data encoding/decoding library and utility apps
    dcmect   - a library for working with Enhanced CT objects
    dcmfg    - a library for working with functional groups
    dcmimage - adds support for color images to dcmimgle
    dcmimgle - an image processing library and utility apps
    dcmiod   - a library for working with information objects and modules
    dcmjpeg  - a compression/decompression library and utility apps
    dcmjpls  - a compression/decompression library and utility apps
    dcmnet   - a networking library and utility apps
    dcmpmap  - a library for working with parametric map objects
    dcmpstat - a presentation state library and utility apps
    dcmqrdb  - an image database server
    dcmrt    - a radiation therapy library and utility apps
    dcmseg   - a library for working with segmentation objects
    dcmsign  - a digital signature library and utility apps
    dcmsr    - a structured reporting library and utility apps
    dcmtls   - security extensions for the network library
    dcmtract - a library for working with tractography results
    dcmwlm   - a modality worklist database server
    oflog    - a logging library based on log4cplus
    ofstd    - a library of general purpose classes
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

To run container outside of this environment: ml bidstools/1.0.1

----------------------------------
