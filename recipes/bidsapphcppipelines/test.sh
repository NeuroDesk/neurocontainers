freeview
wb_view

wget https://raw.githubusercontent.com/bids-apps/maintenance-tools/main/utils/get_data_from_osf.sh
bash get_data_from_osf.sh hcp_example_bids_v3
run.py ~/data/hcp_example_bids_v3/ ~/temp/hcp-bids/ participant --participant_label 100307 --stages PreFreeSurfer --processing_mode legacy --license_key="*CxjskRdd7" --n_cpus 2