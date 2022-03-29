
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
dicomsort dicomfolder
bidsmapper dicomfolder bidsoutputfolder
bidscoiner dicomfolder bidsoutputfolder

```

More documentation can be found here:
https://bidscoin.readthedocs.io/en/latest/installation.html
https://github.com/rordenlab/dcm2niix


Citation:
```
Zwiers MP, Moia S, Oostenveld R. BIDScoin: A User-Friendly Application to Convert Source Data to Brain Imaging Data Structure. Front Neuroinform. 2022 Jan 13;15:770608. doi: 10.3389/fninf.2021.770608. PMID: 35095452; PMCID: PMC8792932.
```

To run container outside of this environment: ml bidscoin/3.7.0

----------------------------------
