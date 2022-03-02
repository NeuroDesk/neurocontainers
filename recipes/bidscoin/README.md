
----------------------------------
## bidscoin/3.7.0 ##
Contains a collection of tools needed for DICOM to BIDS conversion, as well as MRS spectroscopy and physiological data to BIDS conversion

Example:
```
dcm2niix
bidsmapper
bidscoiner
bidseditor
bidsparticipants
deface
medeface
dicomsort
rawmapper

convert dicom to bids:
dicomsort dicomfolder/sub-folder -r -e .IMA
bidsmapper dicomfolder bidsoutputfolder
bidscoiner dicomfolder bidsoutputfolder

```

More documentation can be found here:
https://bidscoin.readthedocs.io/en/latest/installation.html
https://github.com/rordenlab/dcm2niix


To run container outside of this environment: ml bidscoin/3.7.0

----------------------------------
