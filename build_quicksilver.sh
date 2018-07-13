imageName='quicksilver'
buildDate=`date +%Y%m%d`

#install neurodocker
#pip3 install --no-cache-dir https://github.com/kaczmarj/neurodocker/tarball/master --user

#upgrade neurodocker
#pip install --no-cache-dir https://github.com/kaczmarj/neurodocker/tarball/master --upgrade

neurodocker generate \
	--base ubuntu:xenial \
	--pkg-manager apt \
        --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
        --run="chmod +x /usr/bin/ll" \
	--copy cuda.deb /cuda.deb \
	--run="dpkg -i /cuda.deb" \
	--run="rm /cuda.deb" \
	--install cuda \
        --workdir /90days \
        --workdir /30days \
	--workdir /QRISdata \
       	--workdir /RDS \
	--workdir /data \
        --workdir /short \
	--user=neuro \
	--workdir /home/neuro \
	--no-check-urls \
	> Dockerfile.${imageName}

docker build -t ${imageName}:$buildDate -f  Dockerfile.${imageName} .

#test:
#docker run -it ${imageName}:$buildDate
#exit 0


docker tag ${imageName}:$buildDate caid/${imageName}:$buildDate
#docker login
docker push caid/${imageName}:$buildDate
docker tag ${imageName}:$buildDate caid/${imageName}:latest
docker push caid/${imageName}:latest

echo "BootStrap:docker" > Singularity.${imageName}
echo "From:caid/${imageName}" >> Singularity.${imageName}

rm ${imageName}_${buildDate}.simg
sudo singularity build ${imageName}_${buildDate}.simg Singularity.${imageName}

#singularity shell --bind $PWD:/data ${imageName}_${buildDate}.simg
#singularity exec --bind $PWD:/data fsl_robex_20180305.simg runROBEX.sh /data/magnitude.nii.nii /data/stripped.nii /data/mask.nii

