#
# app_test.sh - Application testing script
# ========================================
#
# This script should contain an automatic functional test of the application that makes it possible to test if everything was correctly installed within the container.
# The Neurodesktop administrator will run it before every release of Neurodesktop.
# If the test fails, the administrator will try to fix the problem (possible contacting you about it), or alternatively, mark the container as faulty in the specific Neurodesktop release.
#
# The script:
# - should return 0 exit code if the container passed the test
# - should return a non-zero exit code if the container failed the test, and an error message (if available) should be printed to stderr 
#   (to send output of any bash command to stderr, add "1>&2" at the end of the command)
# - should return 1 exit code and print "N/A" to stderr if the container developer hasn't written a test script yet
#   (that will be the default if the developer uses this example as-is)
# Notide that any other stderr or stdout will be captured when running the script and provided to the administrator as part of the testing. That said,
# given that many applications are tested, the administrator may not monitor the output and rely primarily on the exit code.
#
# The script must be a bash script, as it will be executed using 'bash -e /neurodesk/test.sh'. 
# The '-e' flag indicates to bash that if there is an error in the script, it should quit immediately with the non-zero exit code of the error rather than the bash default of continuing script execution after an error. This way errors in the script won't be overlooked during testing (the script continuing and returning zero exit code on termination, the administrator might not notice the error message).
#
# Notice that the script can also be executed by users directly by running /neurodesk/test.sh within the container. This can be used to double-check that the application works properly in the specific environment used by the user (although Singularity containers are supposed to run identically regardless of the execution environment, there are some excpetions).
#

# The variables below should be set according to the tested app. They are just used as an example
URL='https://download_url'               # URL of test data
EXEC='process'                           # executable of app
ARGUMENTS='-all -inv test_input'         # arguments for executable

# download test data (in this case, we assume it includes a folder 'input' with the input data, and a folder 'output' with expected output data.
if curl -L "$URL"  > download.zip && unzip download.zip
then
	   echo 'app_test.sh: Downloaded data from '"$URL"' successfuly'
else
	   exit_code=$?
	   echo 'app_test.sh: Cannot download test data from '"$URL"'. Return non-zero exit code' 1>&2
	   exit "$exit_code"
fi

# delete output folder, to make sure we do not use output of previous tests
if [ -d test_output ]
then
	    rm -Rf test_output
fi

# execute app
if "$EXEC" arguments test_output
then
	   echo 'app_test.sh: found '"$EXEC"' and executed it (but might be unsuccessful)'
else
 	  exit_code=$?
	   echo 'app_test.sh: executing '"$EXEC"' returned an error. Return non-zero exit code' 1>&2
	   exit "$exit_code"
fi

# compare 
if diff -r test_output output
then
	echo 'test.sh: MFCSC test successful'
else
	exit_code=$?
	echo 'test.sh: Generated output does not match expected output. Return non-zero exit code' 1>&2
	exit "$exit_code"
fi
Footer

 
