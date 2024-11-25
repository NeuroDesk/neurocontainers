# Test tool on its own:
pip install osfclient
osf -p ru43c fetch 01_bids.zip
unzip 01_bids.zip
cd 01_bids/sub-170705134431std1312211075243167001/ses-1/anat
cp sub-170705134431std1312211075243167001_ses-1_run-1_part-mag_T2starw.nii input.nii
mri_synthstrip -i input.nii -o stripped.nii.gz -m mask.nii.gz 
quickshear input.nii mask.nii.gz defaced.nii.gz
cp defaced.nii.gz /data
cp stripped.nii.gz /data




## Test openrecon side:

# convert dicom to ismrmrd
cd /opt/code/python-ismrmrd-server

# pip install osfclient
# osf -p ru43c fetch GRE_2subj_1mm_TE20ms/sub1/GR_M_5_QSM_p2_1mmIso_TE20.zip
# unzip GR_M_5_QSM_p2_1mmIso_TE20.zip
# python3 dicom2mrd.py -o /data/input_data.h5 GR_M_5_QSM_p2_1mmIso_TE20

python3 dicom2mrd.py -o /data/input_data_daniel.h5 /data/dicom_data


#  "python3", "/opt/code/python-ismrmrd-server/main.py", "-v", "-r", "-H=0.0.0.0", "-p=9002", "-l=/tmp/python-ismrmrd-server.log", "-s", "-S=/tmp/share/saved_data"]')

python3 /opt/code/python-ismrmrd-server/main.py -v -r -H=0.0.0.0 -p=9002 -s -S=/tmp/share/saved_data &
# wait until you see Serving ... and the press ENTER
# remove previous file outputs
# remove old nifti output data

python3 /opt/code/python-ismrmrd-server/client.py -G dataset -o /data/openrecon_output_daniel.h5 /data/input_data_daniel.h5
cp input.nii /data/input_image_daniel.nii
cp defaced.nii.gz /data/defaced_daniel.nii.gz
cp stripped.nii.gz /data/stripped_daniel.nii.gz
