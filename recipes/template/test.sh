# This script should contain an automatic functional test of the tool that makes it possible to test if everything was correctly installed
# It will be ran before every release of Neurodesktop
#
# 
#
# The script must be a bash script, as it will be executed using 'bash -e /neurodesk/test.sh'. 
# The '-e' flag indicates to bash that if there is an error in the script, it should quit immediately with the non-zero exit code of the error rather than the bash default of continuing script execution after an error. This way errors in the script won't be overlooked during testing (the script returning zero exit code, the operator might not notice the error message).
# That said, the script can also be executed by users directly by running /neurodesk/test.sh within the container.

 
