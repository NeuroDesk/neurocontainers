
----------------------------------
## freesurfer/7.1.1 ##
FreeSurfer contains a set of programs with a common focus of analyzing magnetic resonance imaging scans of brain tissue. It is an important tool in functional brain mapping and contains tools to conduct both volume based and surface based analysis.

Example:
```
mkdir /vnm/freesurfer_output
export SUBJECTS_DIR=/vnm/freesurfer_output
recon-all -subject subjectname -i invol1 -all
```

More documentation can be found here: https://surfer.nmr.mgh.harvard.edu/fswiki/recon-all

Before using Freesurfer you need to request a license here (https://surfer.nmr.mgh.harvard.edu/registration.html) and store it in your homedirectory as ~/.license

e.g.:
```
echo "Steffen.Bollmann@cai.uq.edu.au
> 21029
>  *Cqyn12sqTCxo
>  FSxgcvGkNR59Y" >> ~/.license

export FS_LICENSE=~/.license 
```

note: FreeSurfer 6.0.0 does not yet support the FS_LICENSE variable, so the license file needs to be included in the container at /opt/freesurfer-6.0.0/license.txt

To run container outside of this environment: ml freesurfer/7.1.1

----------------------------------
