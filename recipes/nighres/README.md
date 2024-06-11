
----------------------------------
## nighres/toolVersion ##
Neuroimaging at high resolution is a collection of python/java tools for processing
of high resolution neuroimaging data, including UHF-MRI and microscopy. 
The package includes many tools for quantitative MRI, brain parcellation, shape analysis 
optimized to scale nicely with resolution.

Example:
```
cp /opt/nighres ~/ -r
cd ~/nighres
python examples/testing_01_quantitative_mri.py 
python examples/testing_02_cortical_laminar_analysis.py
python examples/testing_03_brain_slab_coregistration.py
python examples/testing_04_massp_subcortex_parcellation.py
```

Tests:
```
cp /opt/nighres ~/ -r
cd ~/nighres
make smoke_tests
```

More documentation can be found here: https://nighres.readthedocs.io/en/latest/

To make the executables and scripts inside this container transparently available in the command line of environments where Neurocommand is installed: ml nighres/toolVersion

Citation:
```
Huntenburg, Steele & Bazin (2018). Nighres: processing tools for high-resolution neuroimaging. 
GigaScience, 7(7). https://doi.org/10.1093/gigascience/giy082
```
(see also specific citations in individual python modules you use)

License: Apache 2.0 https://github.com/nighres/nighres?tab=Apache-2.0-1-ov-file#readme

----------------------------------
