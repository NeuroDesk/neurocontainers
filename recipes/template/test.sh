# This script should contain an automatic functional test of the application that makes it possible to test if everything was correctly installed within the container.
# The Neurodesktop administrator will run it before every release of Neurodesktop.
# If the test fails, the administrator will try to fix the problem (possible contacting you about it), or alternatively, mark the container as faulty in the specific Neurodesktop release.
#
# The script must be a bash script, as it will be executed using 'bash -e /neurodesk/test.sh'. 
# The '-e' flag indicates to bash that if there is an error in the script, it should quit immediately with the non-zero exit code of the error rather than the bash default of continuing script execution after an error. This way errors in the script won't be overlooked during testing (the script continuing and returning zero exit code on termination, the administrator might not notice the error message).
#
# Notice that the script can also be executed by users directly by running /neurodesk/test.sh within the container. This can be used to double-check that the application works properly in the specific environment used by the user (although Singularity containers are supposed to run identically regardless of the execution environment, there are some excpetions).

 
