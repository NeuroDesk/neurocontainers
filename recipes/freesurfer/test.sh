segmentSubjectT1_autoEstimateAlveusML #should not complain about libraries missing
checkMCR.sh #should not complain
segmentThalamicNuclei.sh --help #should not compalin about matlab libraries missing

# interactive test:
if [[ -v DISPLAY ]]; then
    export QT_DEBUG_PLUGINS=1
    freeview
fi