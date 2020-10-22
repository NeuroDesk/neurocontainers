# Automatic Container building and testing

The containers can for be used in combination with our transparent singularity or neurodesk tool, that wrap the executables inside a container to make them easily available for pipelines:
https://github.com/NeuroDesk/transparent-singularity/
https://github.com/NeuroDesk/neurodesk/

The containers are hosted on dockerhub (https://hub.docker.com/orgs/vnmd/repositories)

## currently available tools:
https://github.com/NeuroDesk/caid/packages
* ![afni](https://github.com/NeuroDesk/caid/workflows/afni/badge.svg)
* ![ants](https://github.com/NeuroDesk/caid/workflows/ants/badge.svg)
* ![ashs](https://github.com/NeuroDesk/caid/workflows/ashs/badge.svg)
* ![convert3d](https://github.com/NeuroDesk/caid/workflows/convert3D/badge.svg)
* ![freesurfer](https://github.com/NeuroDesk/caid/workflows/freesurfer/badge.svg)
* ![fsl](https://github.com/NeuroDesk/caid/workflows/fsl/badge.svg)
* ![itksnap](https://github.com/NeuroDesk/caid/workflows/itksnap/badge.svg)
* ![julia](https://github.com/NeuroDesk/caid/workflows/julia/badge.svg)
* ![lashis](https://github.com/NeuroDesk/caid/workflows/lashis/badge.svg)
* ![minc](https://github.com/NeuroDesk/caid/workflows/minc/badge.svg)
* ![mrtrix3](https://github.com/NeuroDesk/caid/workflows/mrtrix3/badge.svg)
* ![spinalcordtoolbox](https://github.com/NeuroDesk/caid/workflows/spinalcordtoolbox/badge.svg)
* ![tgvqsm](https://github.com/NeuroDesk/caid/workflows/tgvqsm/badge.svg)


# pull containers
docker
```
docker pull vnmd/julia_1.4.1
```

singularity from dockerhub
```
singularity pull docker://vnmd/julia_1.4.1
```

# Adding new recipes
Refer to neurodocker for more information on neurodocker recipes  
https://github.com/NeuroDesk/neurodocker  
To add an application (e.g. _newapp_), follow these steps.
1. Clone the repository
1. Create the directory _newapp_ in `caid/recipes`
2. Add a `build.sh` to `caid/recipes/_newapp_`
3. Run update-builders.sh from caid. This will auto-create the CI workflow for the application
4. git commit and push
