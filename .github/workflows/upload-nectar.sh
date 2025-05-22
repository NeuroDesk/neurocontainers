echo "[DEBUG] Attempting upload to Nectar Object Storage:"

IMAGENAME=$1
export IMAGE_HOME="/storage/tmp"


time rclone copy $IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.simg nectar:/neurodesk/temporary-builds-new
echo "[DEBUG] Done with uploading to Nectar Object Storage!"