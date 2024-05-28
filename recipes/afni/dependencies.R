# R Script to install the dependencies
if("data.table" %in% rownames(installed.packages()) == FALSE) {install.packages("data.table", repos = "http://cran.us.r-project.org")}
if("cmdstanr" %in% rownames(installed.packages()) == FALSE) {install.packages("cmdstanr", repos = "https://mc-stan.org/r-packages/")}