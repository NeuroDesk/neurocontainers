segmentSubjectT1_autoEstimateAlveusML #should not complain about libraries missing
checkMCR.sh #should not complain
segmentThalamicNuclei.sh --help #should not compalin about matlab libraries missing
mris_left_right_register # should not through permission denied error (was an apparmor problem)
segmentNuclei # should work and not return a symbol error (if it does it uses the wrong matlab mcr version)

# interactive test:
if [[ -v DISPLAY ]]; then
    export QT_DEBUG_PLUGINS=1
    freeview
fi

[ -f ./mp2rage.nii  ] && echo "$FILE exist." || wget https://imaging.org.au/uploads/Human7T/mp2rageModel_L13_work03-plus-hippocampus-7T-sym-norm-mincanon_v0.8.nii -O ./mp2rage.nii 
mkdir ./freesurfer_output
recon-all -subject subjectname -i mp2rage.nii -all -sd ./freesurfer_output
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=16
SegmentAAN.sh subjectname ./freesurfer_output
freeview -v $SUBJECTS_DIR/$SUBJECT/T1.mgz -v  $SUBJECTS_DIR/$SUBJECT/arousalNetworkLabels.$SUFFIX.mgz:colormap=lut:lut=$FREESURFER_HOME/average/AAN/atlas/freeview.lut.txt