#!/usr/bin/env bash
set -e

/opt/lcmodel-6.3/install-lcmodel

cp /opt/lcmodel-6.3/.lcmodel/license /home/user/.lcmodel/

cp /opt/lcmodel-6.3/.lcmodel/basis-sets/* /home/user/.lcmodel/basis-sets/ -R

cp /opt/${toolName}-${toolVersion}/.lcmodel/profiles/ /home/user/.lcmodel/ -R