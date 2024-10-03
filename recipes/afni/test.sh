# Test AFNI functions
afni_system_check.py -check_all
afni_system_check.py -disp_ver_pylibs flask flask_cors

#Test freesurfer functions
\@SUMA_Make_Spec_FS -NIFTI -fspath /opt/freesurfer-7.4.1/subjects/fsaverage/surf -sid fsaverage


# Test R
R 
library("data.table")


# Test cmdstanr
R
library(cmdstanr)
cmdstanr::set_cmdstan_path("/opt/cmdstan-2.35.0/")
file <- file.path(cmdstan_path(), "examples", "bernoulli", "bernoulli.stan")
mod <- cmdstan_model(file)
mod$print()
mod$exe_file()

data_list <- list(N = 10, y = c(0,1,0,0,0,0,0,0,0,1))

fit <- mod$sample(
  data = data_list,
  seed = 123,
  chains = 4,
  parallel_chains = 4,
  refresh = 500 # print update every 500 iters
)

# Test 3dLMEr
tar xvzf test.tgz
bash run.LMEr.txt

# Test SUMA bug
The suma crashes were triggered by a quite specific action: after opening suma, go to View > Object controller, then when I clicked and dragged the slider to adjust the T-threshold it would crash.
