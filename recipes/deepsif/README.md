
----------------------------------
## deepsif/0.0.1 ##
Container enviroment for Deep Learning based Source Imaging Framework (DeepSIF)
Including pytorch, numpy mne h5py tvb and cuda11.5 cudnn 8.3.0.98

Example:
```
singularity exec --nv deepsif.simg /opt/miniconda-4.7.12/envs/deepsif-0.0.1/bin/python3 DeepSIF/forward/generate_tvb_data.py --a_start 0 --a_end 994

More documentation can be found here: https://github.com/bfinl/DeepSIF
The python environment: /opt/miniconda-4.7.12/envs/deepsif-0.0.1/bin/python3

This container do not contain MATLAB. 
```



To run applications outside of this container: ml deepsif/0.0.1

Citation:
```
Sun, R., Sohrabpour, A., Worrell, G. A., & He, B. (2022). Deep neural networks constrained by neural mass models improve electrophysiological source imaging of spatiotemporal brain dynamics. Proceedings of the National Academy of Sciences of the United States of America, 119(31), e2201128119. https://www.pnas.org/doi/full/10.1073/pnas.2201128119
```

----------------------------------
