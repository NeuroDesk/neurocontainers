cp FastCSR/ ~/ -r
cd ~/FastCSR/ 
python3 pipeline.py --sd ./data --sid sub-001  --t1 ./data/sub-001.nii.gz --parallel_scheduling off --verbose --optimizing_surface off