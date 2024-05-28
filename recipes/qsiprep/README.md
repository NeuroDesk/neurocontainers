
----------------------------------
## qsiprep/toolVersion ##
qsiprep configures pipelines for processing diffusion-weighted MRI (dMRI) data. The main features of this software are
- A BIDS-app approach to preprocessing nearly all kinds of modern diffusion MRI data.
- Automatically generated preprocessing pipelines that correctly group, distortion correct, motion correct, denoise, coregister and resample your scans, producing visual reports and QC metrics.
- A system for running state-of-the-art reconstruction pipelines that include algorithms from Dipy, MRTrix, DSI Studio and others.
- A novel motion correction algorithm that works on DSI and random q-space sampling schemes

usage: 
```
qsiprep [-h] [--version] [--skip_bids_validation]
               [--participant_label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...]]
               [--bids-database-dir BIDS_DATABASE_DIR]
               [--bids-filter-file FILE] [--interactive-reports-only]
               [--recon-only] [--recon-spec RECON_SPEC]
               [--recon-input RECON_INPUT]
               [--recon-input-pipeline {qsiprep,ukb,hcpya}]
               [--freesurfer-input FREESURFER_INPUT] [--skip-odf-reports]
               [--nthreads NTHREADS] [--omp-nthreads OMP_NTHREADS]
               [--mem_mb MEM_MB] [--low-mem] [--use-plugin USE_PLUGIN]
               [--anat-only] [--dwi-only] [--infant] [--boilerplate] [-v]
               [--anat-modality {T1w,T2w,none}]
               [--ignore {fieldmaps,phase} [{fieldmaps,phase} ...]]
               [--longitudinal] [--b0-threshold B0_THRESHOLD]
               [--dwi_denoise_window DWI_DENOISE_WINDOW]
               [--denoise-method {dwidenoise,patch2self,none}]
               [--unringing-method {none,mrdegibbs,rpg}] [--dwi-no-biascorr]
               [--b1-biascorrect-stage {final,none,legacy}]
               [--no-b0-harmonization] [--denoise-after-combining]
               [--separate_all_dwis]
               [--distortion-group-merge {concat,average,none}]
               [--write-local-bvecs]
               [--anatomical-template {MNI152NLin2009cAsym}]
               --output-resolution OUTPUT_RESOLUTION
               [--b0-to-t1w-transform {Rigid,Affine}]
               [--intramodal-template-iters INTRAMODAL_TEMPLATE_ITERS]
               [--intramodal-template-transform {Rigid,Affine,BSplineSyN,SyN}]
               [--b0-motion-corr-to {iterative,first}]
               [--hmc-transform {Affine,Rigid}]
               [--hmc_model {none,3dSHORE,eddy,tensor}]
               [--eddy-config EDDY_CONFIG] [--shoreline_iters SHORELINE_ITERS]
               [--impute-slice-threshold IMPUTE_SLICE_THRESHOLD]
               [--skull-strip-template {OASIS,NKI}] [--skull-strip-fixed-seed]
               [--skip-anat-based-spatial-normalization]
               [--fs-license-file PATH] [--do-reconall]
               [--pepolar-method {TOPUP,DRBUDDI,TOPUP+DRBUDDI}]
               [--denoised_image_sdc] [--prefer_dedicated_fmaps]
               [--fmap-bspline] [--fmap-no-demean] [--use-syn-sdc]
               [--force-syn] [-w WORK_DIR] [--resource-monitor]
               [--reports-only] [--run-uuid RUN_UUID] [--write-graph]
               [--stop-on-first-crash] [--notrack] [--sloppy]
               bids_dir output_dir {participant}

example:
qsiprep data/bids_root/ out/ participant -w work/
```

More documentation can be found here: https://qsiprep.readthedocs.io/en/latest/usage.html

To run applications outside of this container: ml qsiprep/toolVersion

----------------------------------
