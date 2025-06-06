---
title: New container {{ env.IMAGENAME_TEST }}
labels: enhancement
---
There is a new container by @{{ env.GITHUB_ACTOR }}, use this command to test on Neurodesk (either a local installation or https://play.neurodesk.org/):
```
bash /neurocommand/local/fetch_and_run.sh {{ env.IMAGENAME_TEST }} {{ env.BUILDDATE }}
```
Or, for testing directly with Apptainer/Singularity:
```
curl -X GET https://neurocontainers.neurodesk.org/temporary-builds-new/{{ env.IMAGENAME }}_{{ env.BUILDDATE }}.simg -O
singularity shell --overlay /tmp/apptainer_overlay {{ env.IMAGENAME }}_{{ env.BUILDDATE }}.simg
```

If test was successful, then add to apps.json to release to Neurodesk:
https://github.com/NeuroDesk/neurocommand/edit/main/neurodesk/apps.json

Or add to the Open Recon recipes to release for that:
https://github.com/NeuroDesk/openrecon/tree/main/recipes

Please close this issue when completed :)
