
----------------------------------
## diffusiontoolkit/0.6.4.1 ##
Diffusion Toolkit is a set of command-line tools with a GUI frontend that performs data reconstruction and fiber tracking on diffusion MR images. Basically, it does the preparation work for TrackVis.

Features of Diffusion Toolkit includes:
- Handles Diffusion Tensor Imaging (DTI), Diffusion Spectrum Imaging (DSI), Q-Ball Imaging and High Angular Resolution Diffusion Imaging (HARDI) data.
- Takes raw DICOM image as well as Nifti/Analyze image.
- Streamlined workflow. Each step is executable independently.
- Scriptable (for advanced users only). Because the core of the toolkit are a set of command-line programs, it allows users to write their own script to process multiple datasets automatically.
Cross-platform, of course.

Example:
```
dtk
```

Important: To be able to use this tool, you need to request a free license: http://www.trackvis.org/download/

and then enter the details of the license on startup, e.g.:
Steffen Bollmann
University of Queensland
9008-F8D8-330B-8274-2EA3-189A-6526-A0D4


More documentation can be found here: http://www.trackvis.org/dtk/

To run applications outside of this container: ml diffusiontoolkit/0.6.4.1

Citation:
```
You may use acknowledgement like "Ruopeng Wang, Van J. Wedeen, TrackVis.org, Martinos Center for Biomedical Imaging, Massachusetts General Hospital" or cite the related ISMRM abstract Proc. Intl. Soc. Mag. Reason. Med. 15 (2007) 3720
```

----------------------------------
