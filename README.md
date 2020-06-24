# Sub-containers for VNM

The containers can for be used in combination with our transparent singularity or neurodesk tool, that wraps the executables inside a container to make them easily available for pipelines:
https://github.com/NeuroDesk/transparent-singularity/
https://github.com/NeuroDesk/neurodesk/

The containers are hosted on dockerhub (https://hub.docker.com/orgs/vnmd/repositories) and on SWIFT storage hosted in Australia (https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages).

The build scripts need to be executed in bash (WSL for windows will work).

## currently available tools
| Tool       | Version                               | Australian Singularity SWIFT | Dockerhub |
|------------|---------------------------------------|------------------------------|-----------|
| AFNI       | afni_20.1.02_20200427.sif             | yes                          | no        |
|            | afni_20.1.06_20200522.sif             | yes                          | no        |
|            | afni_20.1.17_20200622.sif             | yes                          | yes       |
| ANTS       | ants_2.3.1_20200422.sif               | yes                          | no        |
|            | ants_2.3.1_20200622.sif               | yes                          | yes       |
| Convert3d  | convert3d_1.0.0_20200420.sif          | yes                          | no        |
|            | convert3d_1.0.0_20200622.sif          | yes                          | yes       |
| Freesurfer | freesurfer_6.0.1_20200506.sif         | yes                          | no        |
|            | freesurfer_7.1.0_20200521.sif         | yes                          | no        |
|            | freesurfer_7.1.0_20200622.sif         | yes                          | yes       |
| FSL        | fsl_6.0.2_20200514.sif                | yes                          | no        |
|            | fsl_6.0.2_20200622.sif                | yes                          | yes       |
|            | fsl_6.0.3_20200422.sif                | yes                          | no        |
| ITKsnap    | itksnap_3.8.0_20200505.sif            | yes                          | no        |
| Julia      | julia_1.4.1_20200508.sif              | yes                          | no        |
|            | julia_1.4.1_20200622.sif              | yes                          | yes       |
| Minc       | minc_1.9.17_20200427.sif              | yes                          | no        |
|            | minc_1.9.17_20200622.sif              | yes                          | yes       |
| MRTrix     | mrtrix3_3.0.0_20200514.sif            | yes                          | no        |
| TGV QSM    | tgvqsm_fsl_5p0p11_intel_20180730.simg | yes                          | no        |
|            | tgvqsm_intel_2630_20181018.simg       | yes                          | no        |

# pull containers
docker
```
docker pull vnmd/julia_1.4.1:20200622
```

singularity from dockerhub
```
singularity pull docker://vnmd/julia_1.4.1:20200622
```

singularity from Australian Swift Storage
```
export containerName=julia_1.4.1_20200622.sif
curl -v -s -S -X GET https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages/${containerName} -O
```