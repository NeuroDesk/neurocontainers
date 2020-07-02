# Automatic Container building and testing

The containers can for be used in combination with our transparent singularity or neurodesk tool, that wrap the executables inside a container to make them easily available for pipelines:
https://github.com/NeuroDesk/transparent-singularity/
https://github.com/NeuroDesk/neurodesk/

The containers are hosted on dockerhub (https://hub.docker.com/orgs/vnmd/repositories)

## currently available tools
```
docker search vnmd
```
[list all available containers](Containerlist.md)

# pull containers
docker
```
docker pull vnmd/julia_1.4.1
```

singularity from dockerhub
```
singularity pull docker://vnmd/julia_1.4.1
```