#!/bin/bash

cd /neurodesktop-storage || exit
# rm without warning if folder doesn't exist
rm -r mrsi_pipeline_neurodesk || true
git clone https://github.com/korbinian90/mrsi_pipeline_neurodesk.git
