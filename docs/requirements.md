# NeuroContainer Requirements

- Have `bash` installed (used to check commands for transperent-singularity).
- Has a `README.md` file at `/README.md`.
- Has global mount points created with `mkdir -p ${mountPointList}`.
- Has a `ll` command with an alias to `ls -la`.
- Has a `DEPLOY_BINS` environment variable to specify commands to expose with transperent-singularity.

A minimal example with NeuroDocker is...

```shell
#!/usr/bin/env bash
set -e

export toolName='example'
export toolVersion='1.0.0'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
    --base-image ubuntu \
    --pkg-manager apt \
    --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
    --run="chmod +x /usr/bin/ll" \
    --run="mkdir -p ${mountPointList}" \
    --env DEPLOY_BINS=uname \
    --copy README.md /README.md \
 > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
```
