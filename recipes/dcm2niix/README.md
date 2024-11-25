
----------------------------------
## dcm2niix/v1.0.20240202' ##
dcm2niix is designed to convert neuroimaging data from the DICOM format to the NIfTI format. This web page hosts the developmental source code - a compiled version for Linux, MacOS, and Windows of the most recent stable release is included with MRIcroGL. A full manual for this software is available in the form of a NITRC wiki.

Example:
```
./dcm2niix ./test-dicom-dir -b y 
```

More documentation can be found here: (https://github.com/rordenlab/dcm2niix?tab=readme-ov-file)

To make the executables and scripts inside this container transparently available in the command line of environments where Neurocommand is installed: ml dcm2niix/v1.0.20240202

Citation:
```
Li X, Morgan PS, Ashburner J, Smith J, Rorden C (2016) The first step for neuroimaging data analysis: DICOM to NIfTI conversion. J Neurosci Methods. 264:47-56. doi: 10.1016/j.jneumeth.2016.03.001. PMID: 26945974
```

License: This software is open source. The bulk of the code is covered by the BSD license. Some units are either public domain (nifti*.*, miniz.c) or use the MIT license (ujpeg.cpp). See the license.txt file for more details.
https://github.com/rordenlab/dcm2niix/blob/master/license.txt

----------------------------------
