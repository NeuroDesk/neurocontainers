
----------------------------------
## clearswi/1.0.0 ##
Published as CLEAR-SWI. It provides magnetic resonance images with improved vein and iron contrast by weighting a combined magnitude image with a preprocessed phase image. This package has the additional capability of multi-echo SWI, intensity correction, contrast enhancement and improved phase processing. The reason for the development of this package was to solve artefacts at ultra-high field strength (7T), however, it also drastically improves the SWI quality at lower field strength.

Example (run in julia):
```
using CLEARSWI

TEs = [4,8,12] # change this to the Echo Time of your sequence. For multi-echoes, set a list of TE values, else set a list with a single TE value.
nifti_folder = CLEARSWI.dir("test","testData","small") # replace with path to your folder e.g. nifti_folder="/data/clearswi"
magfile = joinpath(nifti_folder, "Mag.nii") # Path to the magnitude image in nifti format, must be .nii or .hdr
phasefile = joinpath(nifti_folder, "Phase.nii") # Path to the phase image

mag = readmag(magfile);
phase = readphase(phasefile);
data = Data(mag, phase, mag.header, TEs);

swi = calculateSWI(data);
# mip = createIntensityProjection(swi, minimum); # minimum intensity projection, other Julia functions can be used instead of minimum
mip = createMIP(swi); # shorthand for createIntensityProjection(swi, minimum)

savenii(swi, "<outputpath>/swi.nii"; header=mag.header) # change <outputpath> with the path where you want to save the reconstructed SWI
savenii(mip, "<outputpath>/mip.nii"; header=mag.header)
```

More documentation can be found here: https://github.com/korbinian90/CLEARSWI.jl

----------------------------------
