#!/usr/bin/env bash
set -e

cd /opt/lcmodel-6.3/

./install-lcmodel
# enter "gv -orientation=seascape 2>/dev/null" in the field Enter display (or print) 

cp /opt/lcmodel-6.3/.lcmodel/license ~/.lcmodel/

cp /opt/lcmodel-6.3/.lcmodel/basis-sets/* ~/.lcmodel/basis-sets/ -R

cp /opt/lcmodel-6.3/.lcmodel/profiles/ ~/.lcmodel/ -R