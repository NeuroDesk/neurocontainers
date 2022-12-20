# R Script to install the dependencies
if("rJava" %in% rownames(installed.packages()) == FALSE) {install.packages("rJava")}
if("Rcpp" %in% rownames(installed.packages()) == FALSE) {install.packages("Rcpp")}
if("devtools" %in% rownames(installed.packages()) == FALSE) {install.packages("devtools")}
if("rmarkdown" %in% rownames(installed.packages()) == FALSE) {install.packages("rmarkdown")}
if("plotly" %in% rownames(installed.packages()) == FALSE) {install.packages("plotly")}