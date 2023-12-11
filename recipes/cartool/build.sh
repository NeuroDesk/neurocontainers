export toolName='cartool'
export toolVersion='7608' 

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi
source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:20.04 \
   --env DEBIAN_FRONTEND=noninteractive \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --workdir /opt \
   --install opts='--quiet' wget git curl ca-certificates unzip \
   --run="dpkg --add-architecture i386" \
   --install opts='--quiet' wine xvfb wine32 \
   --env WINEPREFIX=/opt/wine \
   --run="winecfg" \
   --workdir "/opt/wine/drive_c/Program\ Files" \
   --run="wget https://objectstorage.us-ashburn-1.oraclecloud.com/n/sd63xuke79z3/b/neurodesk/o/cartool7608.zip -O cartool7608.zip \
            && unzip cartool7608.zip \
            && rm cartool7608.zip" \
   --env PATH='$PATH':/opt/${toolName}-${toolVersion}/bin \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --copy README.md /README.md \
   --copy license.txt /license.txt                          `# MANDATORY: include license file in container` \
  > ${imageName}.${neurodocker_buildExt}
   
   # this doesn't work yet -> zipping up installation folder for now on an interactive instance.
   # --run="Xvfb :0 -screen 0 1024x768x16 & DISPLAY=:0.0 wine Cartool64Setup.exe /S" \

  
if [ "$1" != "" ]; then
   ./../main_build.sh
fi
