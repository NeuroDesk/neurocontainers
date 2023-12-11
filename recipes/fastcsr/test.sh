pip list | grep numpy
# numpy==1.20.3             

pip list | grep nibabel
# nibabel             2.5.2

cd /opt/FastCSR
python3 pipeline.py --sd ./data --sid sub-001  --t1 ./data/sub-001.nii.gz --parallel_scheduling off --verbose

# DOENS'T WORK
# [INFO] 2023-12-08 07:10:30 PID: 15 pipeline.py Please cite the following paper when using FastCSR:
# ****************************************
# [INFO] 2023-12-08 07:10:30 PID: 15 pipeline.py ------------------------Generate mri/orig.mgz file--------------------------------
# [INFO] 2023-12-08 07:10:30 PID: 15 pipeline.py The mri/orig.mgz file already exists, skip this step.
# [INFO] 2023-12-08 07:10:30 PID: 15 pipeline.py -----------------------Generate mri/filled.mgz file-------------------------------
# [INFO] 2023-12-08 07:10:30 PID: 15 pipeline.py The mri/filled.mgz file already exists, skip this step.
# [INFO] 2023-12-08 07:10:30 PID: 15 pipeline.py --------------------Generate mri/aseg.presurf.mgz file----------------------------
# [INFO] 2023-12-08 07:10:30 PID: 15 pipeline.py The mri/aseg.presurf.mgz file already exists, skip this step.
# [INFO] 2023-12-08 07:10:30 PID: 15 pipeline.py ---------------------Generate mri/brainmask.mgz file------------------------------
# [INFO] 2023-12-08 07:10:30 PID: 15 pipeline.py The mri/brainmask.mgz file already exists, skip this step.
# [INFO] 2023-12-08 07:10:30 PID: 15 pipeline.py -------------------------Generate mri/wm.mgz file---------------------------------
# [INFO] 2023-12-08 07:10:30 PID: 15 pipeline.py The mri/wm.mgz file already exists, skip this step.
# [INFO] 2023-12-08 07:10:30 PID: 15 pipeline.py -------------------Generate mri/?h_levelset.nii.gz file---------------------------
# [ERROR] 2023-12-08 07:10:47 PID: 15 pipeline.py Levelset regression model inference failed.