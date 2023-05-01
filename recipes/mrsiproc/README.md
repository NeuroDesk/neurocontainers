
----------------------------------
## mrsiproc/0.0.1 ##

Includes the following:  
##### -- OS: Ubuntu 20.04 (Built off Matlab 2022a Deep learning Docker)
##### -- Minc 						(Version 1.9.15)
##### -- MATLAB 					(Version R2021b)
##### -- HD-BET           (Version 1.0)
##### -- tar
##### -- gzip
##### -- gunzip
##### -- LCModel 					(Version 6.3.1)
##### -- dcm2nii
##### -- Python           (Version 3.10)
##### -- Julia            (Version 1.9.0-rc2)


Overview
--------------------------------------------
In its current stage, the container provides the environment, but the scripts need to be obtained separately.

Setup
---------------------------------------------
  ### Start neuredesktop with a fixed mac-address
  Add the option `--mac-address 02:42:ac:11:00:02` to the docker command used for starting Neurodesk (see https://www.neurodesk.org/docs/neurodesk/getting-started/).  
  This ensures that the license can still be used after rebooting Neurodesk.   
  Example for the Linux command to start Neurodesk:
  ```bash
  sudo docker run \
  --shm-size=1gb -it --privileged --name neurodesktop \
  --mac-address 02:42:ac:11:00:02 \
  -v ~/neurodesktop-storage:/neurodesktop-storage \
  -e HOST_UID="$(id -u)" -e HOST_GID="$(id -g)"\
  -p 8080:8080 \
  -h neurodesktop-20220813 vnmd/neurodesktop:20220813
  ```
  (The mac address can be different from the one used here, but it must match the one used as host name for activating the matlab license)

  ### MRSI Scripts
  This container does not contain scripts for mrsi processing yet.  
  They need to be stored under `neurodesktop-storage` and the path set in `InstallProgramPaths.sh`

  ### MATLAB license
  The MATLAB license can be obtained from https://au.mathworks.com/licensecenter
  - Log in with your account  
  - Click on the license number
  - Select the tab "Install and Activate"
  - In "Related Tasks" click on "Activate to Retrieve License File"
  - Click "Activate a Computer"
  - Enter the Information:  
    Release: R2021b  
    Operating System: Linux  
    Host ID: 02:42:ac:11:00:02  
    Computer Login Name: root
  - When it says 'is the software installed', select yes
  - Then select 'download license'
  - Store the license under /neurodesktop-storage/license_matlab.lic  
  
Run MRSI scripts
-----------------------------------------
Run the scripts from within a singularity shell inside Neurodesk. Example:
```bash
singularity shell singularity shell /cvmfs/neurodesk.ardc.edu.au/containers/mrsiproc_0.0.1_20221026/mrsiproc_0.0.1_20221026.simg
```
```bash
Singularity> cd /neurodesktop-storage/mrsi_proc
Singularity> ./Run_MRSI_test.sh
```

To run applications outside of this container
---------------------------------------------
  (This is not working yet)  
  ml mrsiproc/0.0.1

Citation
--------
  
  see individual Neurodesk containers for abovementioned software.

----------------------------------
