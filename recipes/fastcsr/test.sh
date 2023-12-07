pip list | grep numpy
# should not be 1.16.4

cd /opt/FastCSR
python3 pipeline.py --sd ../data --sid sub-001  --t1 ../data/sub-001.nii.gz
