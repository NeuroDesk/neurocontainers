---
title: New container {{ env.IMAGENAME_TEST }}
labels: enhancement
---
There is a new container by @{{ env.GITHUB_ACTOR }}, use this command to test on Neurodesk:
```
bash /neurocommand/local/fetch_and_run.sh {{ env.IMAGENAME_TEST }} {{ env.BUILDDATE }}
```
Or, for testing directly with Singularity:
```
curl -X GET https://d15yxasja65rk8.cloudfront.net/temporary-builds-new/{{ env.IMAGENAME_TEST }}_{{ env.BUILDDATE }}.simg -O
```

If test was successful, then add to apps.json to release:
https://github.com/NeuroDesk/neurocommand/edit/main/neurodesk/apps.json

Please close this issue when completed :)
