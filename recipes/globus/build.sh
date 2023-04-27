export toolName='globus'
export toolVersion='3.2.0' 

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi
source ../main_setup.sh

echo "installing development repository of neurodocker:"
yes | pip uninstall neurodocker
pip install --no-cache-dir https://github.com/NeuroDesk/neurodocker/tarball/yum_cleanup --upgrade

# The cleanup fix tries to fix the dive warning of wasted space. I tried to do it with awk in here, but not successful
# # replace this
# && rm -rf /var/cache/yum/*

# # with this for better cleanup:
# && rm -rf /var/cache/yum/* \
# && rm -rf /usr/lib/sysimage/rpm/rpmdb.sqlite \
# && rm -rf /var/lib/dnf/history.sqlite-wal


# awk '/rm -rf \/var\/cache\/yum/ { print "\&\& rm -rf \/var\/cache\/yum\/* \\"; print "\&\& rm -rf \/usr\/lib\/sysimage\/rpm\/rpmdb.sqlite \\"; print "\&\& rm -rf \/var\/lib\/dnf\/history.sqlite-wal"; next }1' ${imageName}.${neurodocker_buildExt} >> tmp.Dockerfile
# cp tmp.Dockerfile ${imageName}.${neurodocker_buildExt} 

neurodocker generate ${neurodocker_buildMode} \
   --base-image fedora:37                            `# ubuntu ` \
   --pkg-manager yum                                    `# RECOMMENDED TO KEEP AS IS: desired package manager, has to match the base image (e.g. debian needs apt; centos needs yum)` \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll"   `# RECOMMENDED TO KEEP AS IS: define the ll command to show detailed list including hidden files`  \
   --run="chmod +x /usr/bin/ll"                         `# RECOMMENDED TO KEEP AS IS: make ll command executable`  \
   --run="mkdir -p ${mountPointList}"                   `# MANDATORY: create folders for singularity bind points` \
   --install wget ca-certificates tk tcllib glibc libXScrnSaver   \
   --workdir /opt                                       `# install in opt` \
   --run="wget https://downloads.globus.org/globus-connect-personal/linux/stable/globusconnectpersonal-latest.tgz \
    && tar xzf globusconnectpersonal-latest.tgz \
    && rm -rf globusconnectpersonal-latest.tgz"        `# download and unpack in opt` \
   --env DEPLOY_PATH=/opt/globusconnectpersonal-${toolVersion}/ `# expose binaries` \
   --env PATH='$PATH':/opt/globusconnectpersonal-${toolVersion}/ \
   --copy README.md /README.md                          `# MANDATORY: include readme file in container` \
  > ${imageName}.${neurodocker_buildExt}                `# THIS IS THE LAST COMMENT; NOT FOLLOWED BY BACKSLASH!`
  





if [ "$1" != "" ]; then
   ./../main_build.sh
fi
