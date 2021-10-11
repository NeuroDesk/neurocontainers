# R Script to install the dependencies
if("devtools" %in% rownames(installed.packages()) == FALSE) {install.packages("devtools")}
if("rmarkdown" %in% rownames(installed.packages()) == FALSE) {install.packages("rmarkdown")}
if("plotly" %in% rownames(installed.packages()) == FALSE) {install.packages("plotly")}
if("shiny" %in% rownames(installed.packages()) == FALSE) {install.packages("shiny")}