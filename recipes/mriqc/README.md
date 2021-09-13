
----------------------------------
## mriqc/0.15.2 ##
MRIQC extracts no-reference IQMs (image quality metrics) from structural (T1w and T2w) and functional MRI (magnetic resonance imaging) data.

example for running:
```
mriqc bids-root/ output-folder/ participant
mriqc bids-root/ output-folder/ participant --participant-label S01 S02 S03

usage: mriqc [-h] [--version]
             [--participant_label [PARTICIPANT_LABEL [PARTICIPANT_LABEL ...]]]
             [--session-id [SESSION_ID [SESSION_ID ...]]]
             [--run-id [RUN_ID [RUN_ID ...]]]
             [--task-id [TASK_ID [TASK_ID ...]]]
             [-m [MODALITIES [MODALITIES ...]]] [--dsname DSNAME]
             [-w WORK_DIR] [--verbose-reports] [--write-graph] [--dry-run]
             [--profile] [--use-plugin USE_PLUGIN] [--no-sub] [--email EMAIL]
             [-v] [--webapi-url WEBAPI_URL] [--webapi-port WEBAPI_PORT]
             [--upload-strict] [--n_procs N_PROCS] [--mem_gb MEM_GB]
             [--testing] [-f] [--ica] [--hmc-afni] [--hmc-fsl]
             [--fft-spikes-detector] [--fd_thres FD_THRES]
             [--ants-nthreads ANTS_NTHREADS] [--ants-float]
             [--ants-settings ANTS_SETTINGS] [--deoblique] [--despike]
             [--start-idx START_IDX] [--stop-idx STOP_IDX]
             [--correct-slice-timing]
             bids_dir output_dir {participant,group} [{participant,group} ...]
```

More documentation can be found here: https://mriqc.readthedocs.io/en/stable/running.html

To run applications outside of this container: ml mriqc/0.15.2

----------------------------------

