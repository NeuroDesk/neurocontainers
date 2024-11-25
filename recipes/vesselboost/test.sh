## Test vesselboost on it's own:
python test_time_adaptation.py --ds_path "/root/Desktop/eval_data/" --out_path "/root/Desktop/eval_out/" --pretrained "./saved_models/Init_ep1000_lr1e3_tver" --ep 2000 --prep_mode 4


test_time_adaptation.py --ds_path tof_input --out_path tof_output --pretrained /opt/VesselBoost/saved_models/manual_0429 --ep 100 --prep_mode 4

 chmod a+x angiboost.py
 mkdir tof_input
 cp /data/tof.nii tof_input
 mkdir tof_output
angiboost.py --ds_path tof_input --out_path tof_output --lb_path init_label --pretrained /opt/VesselBoost/saved_models/manual_0429 --outmo tof_output/outmo --ep 100 --lr 0.05 --prep_mode 4



# Test openrecon side:

python3 /opt/code/python-ismrmrd-server/main.py -v -r -H=0.0.0.0 -p=9002 -s -S=/tmp/share/saved_data &
#remove previous output
rm /data/tof_openrecon_output.h5
# remove old nifti output data
rm /data/tof_openrecon_output.nii
python /opt/code/python-ismrmrd-server/client.py -G dataset -o /data/tof_openrecon_output.h5 /data/tof.h5 -c vesselboost
cp tof_output/tof.nii /data/tof_openrecon_output.nii

#TEST GPU capability.

# TODO: Test by giving a config paramter to the client that tests 
#         if config['parameters']['options'] == 'tta':
#         if config['parameters']['options'] == 'booster':