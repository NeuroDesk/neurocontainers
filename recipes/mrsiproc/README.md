
----------------------------------
## mrsiproc/0.0.1 ##

Built off Matlab IDE
includes the following:
##### -- OS: Ubuntu 12.04			(12.04.3 LTS, current used Kernel: GNU/Linux 3.2.0-48-generic x86_64)
##### -- Minc 						(program: 2.0.18, libminc: 2.0.18, netcdf: 3.6.3, HDF5: 1.6.6,)
##### -- MATLAB 					(matlab78R2009a)
##### -- BET 						(of FSL package 4.1, 2008)
##### -- tar 						(Any version should work)
##### -- gzip						(Any version should work)
##### -- gunzip						(Any version should work) #
##### -- LCModel 					(Version 6.3.1)

also does not scripts from Wolfgang - need to have them locally in order to work.
Bind scripts to /opt/mrsiproc/matlab/MatlabFunctions


Matlab IDE

Important note about licensing
------------------------------
  
The Matlab application includes a commercial product, and requires a MATLAB license to run. On first run, a license dialog will appear. Users should follow these steps to activate license:
1. Choose "Activate automatically using the internet" (and press Next)
2. Enter their institutional email address and password (and press Next)
3. Select license to use (and press Next)
4. A username will be displayed (just press Next)

If the user is eligible for a MATLAB license through the institution, the license will be downloaded to the user home directory (inside the ~/.matlab folder). After the license dialog closes, it is required to re-run the Matlab application. The license will be now available for future executions of Matlab, and the dialog will not show again.

To use the application without internet connectivity, it should also be possible to generate a license on the mathworks website, and place it in ~/Downloads (exact file name does not matter, but it should have a .lic extension). The license should be detected automatically when the Matlab application starts (no license dialog will be presented). Generating a license on the Mathworks website requires specifying username and host id. Username can be displayed in Linux by typing 'id' in the terminal. For instructions on how to find your host id, read here: https://au.mathworks.com/matlabcentral/answers/101892-what-is-a-host-id-how-do-i-find-my-host-id-in-order-to-activate-my-license?s_tid=srchtitle



Examples
--------

  LAUNCH INTERACTIVE IDE -
  
  matlab

  RUNNING SCRIPT IN BATCH -
  
  matlab -batch command

  COMPILYING C CODE TO WORK WITH MATLAB -
  
  mex

More documentation can be found here
------------------------------------

  https://hub.docker.com/r/mathworks/matlab-deep-learning
  
  mathworks.com


To run applications outside of this container
---------------------------------------------

  ml mrsiproc/0.0.1

Citation
--------
  
  see individual neurodesk containers for abovementioned software.

----------------------------------
