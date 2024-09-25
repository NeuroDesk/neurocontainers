# R Script to install the dependencies
if("data.table" %in% rownames(installed.packages()) == FALSE) {install.packages("data.table", repos = "http://cran.us.r-project.org")}
if("cmdstanr" %in% rownames(installed.packages()) == FALSE) {install.packages("cmdstanr", repos = "https://stan-dev.r-universe.dev")}
if("lme4" %in% rownames(installed.packages()) == FALSE) {install.packages("lme4", repos = "http://cran.us.r-project.org")}
if("lmerTest" %in% rownames(installed.packages()) == FALSE) {install.packages("lmerTest", repos = "http://cran.us.r-project.org")}
if("phia" %in% rownames(installed.packages()) == FALSE) {install.packages("phia", repos = "http://cran.us.r-project.org")}