## Building a container inside Neurodesktop

This is work in progress. The idea is to interactively build a container, then parse the history and build a recipe:

Access Neurodesk JupyterLab at https://labtokyo.neurodesk.org/ and open a terminal. \
Run the following commands to build a writable Singularity container.

```bash
git clone https://github.com/NeuroDesk/neurocontainers/
cd neurocontainers/interactive_builder
# modify the start container in template (by default ubuntu:22.04)
sudo singularity build --sandbox container.sif template
sudo singularity shell --bind /home/jovyan/neurocontainers/interactive_builder:/root --writable container.sif
```

Now install your application in this Singularity container and test it. \
Once the application works as expected, execute the following script to extract all the commands used for installation.

```bash
sudo apt install python3 
# OR if you choose a yum based distribution earlier
sudo yum install python3
cd /root
chmod a+x automate_script
./automate_script.sh
```

The recipe of your applcation is generated into `/home/jovyan/neurocontainers/interactive_builder/build.sh`. Open an issue an on Neurocontainers paste the file there: https://github.com/NeuroDesk/neurocontainers/issues/new
(Next step: automate the creation of directories and add Readme file)


ToDo:
- needs to detect which base image was used in template and add this to 
   --base-image neurodebian:sid-non-free                `# neurodebian makes it easy to install neuroimaging software, recommended as default` \
