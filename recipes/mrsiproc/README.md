
----------------------------------
## mrsiproc/0.0.1 ##

Includes the following:  
##### -- OS: Ubuntu 20.04 (Built off Matlab 2022a Deep learning Docker)
##### -- Minc 						(Version 1.9.15)
##### -- MATLAB 					(Version R2022a)
##### -- HD-BET           (Version 1.0)
##### -- tar
##### -- gzip
##### -- gunzip
##### -- LCModel 					(Version 6.3.1)
##### -- dcm2nii


Setup
---------------------------------------------
  ### Start neuredesktop with a fixed mac-address
  Add the option `--mac-address 02:42:ac:11:00:02` to the docker command used for starting neurodesktop (see https://www.neurodesk.org/docs/neurodesktop/getting-started/).  
  This ensures that the license can still be used after rebooting neurodesktop.   
  Example for Windows WSL:
  ```bash
  docker run --shm-size=1gb -it --privileged --name neurodesktop --mac-address 02:42:ac:11:00:02 -v C:/neurodesktop-storage:/neurodesktop-storage -p 8080:8080 -h neurodesktop-20220813 vnmd/neurodesktop:20220813
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
    Release: R2022a  
    Operating System: Linux  
    Host ID: 02:42:ac:11:00:02  
    Computer Login Name: matlab
  - Download the license and store it under /neurodesktop-storage/license_matlab.lic  


To run applications outside of this container
---------------------------------------------

  ml mrsiproc/0.0.1

Citation
--------
  
  see individual neurodesk containers for abovementioned software.

----------------------------------
