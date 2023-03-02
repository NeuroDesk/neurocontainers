## Building a container inside Neurodesktop

This is work in progress. The idea is to interactively build a container, then parse the history and build a recipe:

Request access to the container build system by opening an issue here and let us know which tool you want to add (to avoid duplications) and ask to be added to the neurodesk-user access group: https://github.com/NeuroDesk/neurocontainers/issues/new

Access Neurodesk JupyterLab at https://labtokyo.neurodesk.org/ and open the Neurodesktop and then open a terminal. \
Run the following commands to build a writable Singularity container.

```bash
git clone https://github.com/NeuroDesk/neurocontainers/
cd neurocontainers/interactive_builder
bash run_interactive_builder.sh
```

Now install your application in this Singularity container and test it. \
Once the application works as expected, exit the singularity build environment by pressing CTRL-D or type exit

The recipe of your applcation is generated into final/build.sh and a final/README.md file is generated as well. Add these files to your issue an on Neurocontainers or create a pull request (TODO: Describe how to do this) or write action that grabs files from issue and creates a pull request???
https://stackoverflow.com/questions/68057744/create-pull-request-with-github-action