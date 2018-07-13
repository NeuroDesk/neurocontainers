# Centre for Advanced imaging processing pipeline containers

## Use minc container
```
singularity pull shub://CAIsr/caid:minc_1p9p16

singularity shell CAIsr-caid-master-minc_1p9p16.simg

singularity exec CAIsr-caid-master-minc_1p9p16.simg register
```

## Use fsl container
```
singularity pull shub://CAIsr/caid:fsl_5p0p11

singularity exec CAIsr-caid-master-fsl_5p0p11.simg fsleyes
```


## Build containers
```
./build_*.sh
```
