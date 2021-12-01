using CLEARSWI

TEs = [20] 
nifti_folder = "/neurodesktop-storage/swi-demo/01_bids/sub-170705134431std1312211075243167001/ses-1/anat"
magfile = joinpath(nifti_folder, "sub-170705134431std1312211075243167001_ses-1_acq-qsm_run-1_magnitude.nii.gz")
phasefile = joinpath(nifti_folder, "sub-170705134431std1312211075243167001_ses-1_acq-qsmPH00_run-1_phase.nii.gz") 

mag = readmag(magfile);
phase = readphase(phasefile);
data = Data(mag, phase, mag.header, TEs);

swi = calculateSWI(data);
# mip = createIntensityProjection(swi, minimum); # minimum intensity projection, other Julia functions can be used instead of minimum
mip = createMIP(swi); # shorthand for createIntensityProjection(swi, minimum)

savenii(swi, "/neurodesktop-storage/swi-demo/swi.nii"; header=mag.header) 
savenii(mip, "/neurodesktop-storage/swi-demo/mip.nii"; header=mag.header)