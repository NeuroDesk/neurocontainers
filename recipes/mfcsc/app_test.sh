#!/bin/bash
#export INFO=1 #do not use INFO, as problem when printing info of a sourced file
NEURODESK_FOLDER=/neurodesk # should be /neurodesk in last version
source "$NEURODESK_FOLDER"/fix_bash.sh


if export UNZIP_DISABLE_ZIPBOMB_DETECTION=TRUE && \
      curl -L 'https://files.osf.io/v1/resources/d7j9n/providers/osfstorage/?zip=' > download.zip && \
       unzip download.zip
then
	echo 'test.sh: Downloaded data from OSF project d7j9n successfuly'
else
	exit_code=$?
	echo 'test.sh: Cannot download test data from OSF project d7j9n. Return non-zero exit code' 1>&2
	exit "$exit_code"
fi

if [ -d test_output ]
then
	rm -Rf test_output
fi
if mfcsc input/FC_SC_list.txt input/FC input/SC test_output
then
	echo 'test.sh: found mfcsc and executed it (but might be unsuccessful)'
else
	exit_code=$?
	echo 'test.sh: executing mfcsc returned an error. Return non-zero exit code' 1>&2
	exit "$exit_code"
fi

if diff -r test_output output
then
	echo 'test.sh: MFCSC test successful'
else
	exit_code=$?
	echo 'test.sh: Generated output does not match expected output. Return non-zero exit code' 1>&2
	exit "$exit_code"
fi
