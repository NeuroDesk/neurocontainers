#!/usr/bin/env bash
set -e

if [[ -d ~/.lcmodel/ ]]
then
    echo ".lcmodel exists on your filesystem."
    echo "Would you like to delete the local install and replace it with the new version? (y/n)"
    read varname
    if [[ "$varname" = "y" ]]
    then
        echo "deleting local lcmodel ..."
        rm -rf ~/.lcmodel
        echo "Setting up lcmodel..."
        cp /opt/lcmodel-6.3/.lcmodel/ ~/ -R
        echo "done."
    else
        echo "ok, not changing anything ..."
    fi
else
    echo "Setting up lcmodel..."
    cp /opt/lcmodel-6.3/.lcmodel/ ~/ -R
    echo "done."
fi