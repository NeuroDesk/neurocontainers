# Sub-containers for VNM

The containers can for be used in combination with our transparent singularity or neurodesk tool, that wraps the executables inside a container to make them easily available for pipelines:
https://github.com/NeuroDesk/transparent-singularity/
https://github.com/NeuroDesk/neurodesk/

The containers are hosted on dockerhub (https://hub.docker.com/orgs/vnmd/repositories)

The build scripts need to be executed in bash (WSL for windows will work).

## currently available tools
```
docker search vnmd
```

# pull containers
docker
```
docker pull vnmd/julia_1.4.1
```

singularity from dockerhub
```
singularity pull docker://vnmd/julia_1.4.1
```