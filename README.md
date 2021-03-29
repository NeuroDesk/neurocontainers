# Automatic Container building and testing

The containers can for be used in combination with our transparent singularity or neurodesk tool, that wrap the executables inside a container to make them easily available for pipelines:
https://github.com/NeuroDesk/transparent-singularity/
https://github.com/NeuroDesk/neurodesk/

The containers are hosted on dockerhub (https://hub.docker.com/orgs/vnmd/repositories)

## currently available tools:
https://github.com/NeuroDesk/caid/packages

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
2. Copy the directory template and rename to _newapp_ in `caid/recipes`
3. Modify `build.sh` in `caid/recipes/newapp` to build your application
4. Run update-builders.sh from caid. This will auto-create the CI workflow for the application (or duplicate the template file and rename all occurances of template to _newapp_)
5. git commit and push
