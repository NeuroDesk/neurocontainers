pip list | grep numpy
# numpy==1.20.3             

pip list | grep nibabel
# nibabel             2.5.2

cd /opt/FastCSR
python3 pipeline.py --sd ./data --sid sub-001  --t1 ./data/sub-001.nii.gz --parallel_scheduling off --verbose --optimizing_surface off