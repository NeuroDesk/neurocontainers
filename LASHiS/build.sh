#!/usr/bin/env bash
set -e

export toolName='lashis'
export toolVersion=1.0

source ../main_setup.sh

# export localSingularityBuild='false'
# export localSingularityBuildWritable='true'

neurodocker generate ${neurodocker_buildMode} \
    --base neurodebian:stretch-non-free \
	--pkg-manager apt \
	--run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
	--run="chmod +x /usr/bin/ll" \
	--run="mkdir ${mountPointList}" \
	--install libxt6 libxext6 libxtst6 libgl1-mesa-glx libc6 libice6 libsm6 libx11-6 \
	--copy ../../ashs-fastashs_beta /ashs-fastashs_beta \
	--env ASHS_ROOT="/ashs-fastashs_beta" \
	--ants version=2.3.0 \
	--copy antsJointLabelFusion2.sh /opt/ants-2.3.0/antsJointLabelFusion2.sh \
	--copy LASHiS.sh /LASHiS.sh \
	--entrypoint /LASHiS.sh  > recipe.${imageName}
./../main_build.sh

