
----------------------------------
## globus/toolVersion ##
Globus client

Example:
```
# First run the setup:
globusconnectpersonal -setup

#Follow the instructions in the terminal: 
#1) copy the URL into a browser and generate the Native App Authorization Code
#2) then copy this code and paste it in the terminal
#3) then name the endpoint, e.g. Neurodesktop

# Then start the GUI:
globusconnectpersonal -gui

# If the connection fails, reset the permissions on the key file:
chmod 600 ~/.globusonline/lta/relay-anonymous-key.pem
```

More documentation can be found here: https://www.neurodesk.org/docs/getting-started/neurodesktop/storage/#globus

To make the executables and scripts inside this container transparently available in the command line of environments where Neurocommand is installed: ml globus/toolVersion

----------------------------------
