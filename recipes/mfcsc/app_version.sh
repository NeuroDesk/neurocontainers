#!/bin/bash

#export INFO=1 #do not use INFO, as problem when printing info of a sourced file
NEURODESK_FOLDER=/neurodesk # should be /neurodesk in last version
source "$NEURODESK_FOLDER"/fix_bash.sh

if mfcsc -version | head -2 | tail -1
then
    a=1 # empty command, just so I'll have a then clause. Cannot run mfcsc without if, because then will exit without explaining what was the problem
else
    exit_code=$?
    echo 'version.sh: executing mfcsc returned an error. Return non-zero exit code' 1>&2
 	exit "$exit_code"
fi