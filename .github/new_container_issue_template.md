---
title: New container {{ env.IMAGENAME_TEST }}
assignees: {{ env.GITHUB_ACTOR }}
labels: enhancement
---
There is a new container, use this command to test:
```
bash /neurocommand/local/fetch_and_run.sh {{ env.IMAGENAME_TEST }} {{ env.BUILDDATE }}
```

If test was successful, then add to apps.json to release:
https://github.com/NeuroDesk/neurocommand/edit/main/neurodesk/apps.json

Please close this issue when completed :)