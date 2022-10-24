#!/bin/bash
#run startup scripts for matlab for mrsi proc
MatlabStartupCommand="Paths = regexp(path,':','split');rmpathss = ~cellfun('isempty',strfind(Paths,'Matlab_Functions')); if(sum(rmpathss) > 0);"
export MatlabStartupCommand="${MatlabStartupCommand} x = strcat(Paths(rmpathss), {':'});x = [x{:}]; rmpath(x); end; clear Paths rmpathss x; addpath(genpath('${MatlabFunctionsFolder}'))"