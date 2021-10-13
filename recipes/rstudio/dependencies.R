# R Script to install the dependencies
if("Rcpp" %in% rownames(installed.packages()) == FALSE) {install.packages("Rcpp")}
if("reticulate" %in% rownames(installed.packages()) == FALSE) {install.packages("reticulate")}
if("fastICA" %in% rownames(installed.packages()) == FALSE) {install.packages("fastICA")}
if("devtools" %in% rownames(installed.packages()) == FALSE) {install.packages("devtools")}
if("rmarkdown" %in% rownames(installed.packages()) == FALSE) {install.packages("rmarkdown")}
if("plotly" %in% rownames(installed.packages()) == FALSE) {install.packages("plotly")}
if("shiny" %in% rownames(installed.packages()) == FALSE) {install.packages("shiny")}
if("tidyverse" %in% rownames(installed.packages()) == FALSE) {install.packages("tidyverse")}
if("RColorBrewer" %in% rownames(installed.packages()) == FALSE) {install.packages("RColorBrewer")}
if("paletteer" %in% rownames(installed.packages()) == FALSE) {install.packages("paletteer")}
if("ggpubr" %in% rownames(installed.packages()) == FALSE) {install.packages("ggpubr")}
if("ggthemes" %in% rownames(installed.packages()) == FALSE) {install.packages("ggthemes")}
if("rbokeh" %in% rownames(installed.packages()) == FALSE) {install.packages("rbokeh")}
if("RcppCNPy" %in% rownames(installed.packages()) == FALSE) {install.packages("RcppCNPy")}
if("R.matlab" %in% rownames(installed.packages()) == FALSE) {install.packages("R.matlab")}
if("caret" %in% rownames(installed.packages()) == FALSE) {install.packages("caret", dependencies = c("Depends", "Suggests"))}
if("car" %in% rownames(installed.packages()) == FALSE) {install.packages("car")}
if("BayesFactor" %in% rownames(installed.packages()) == FALSE) {install.packages("BayesFactor", dependencies = TRUE)}