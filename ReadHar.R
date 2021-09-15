#This file does everything for the project: downloading data, manipulating it, creating graphs (or calls the files that do)

#Clear variables
#Source: https://www.geeksforgeeks.org/clear-the-console-and-the-environment-in-r-studio/
rm(list=ls())

option_install_packages=0 #This part only needs to be run once, to install the relevant packages

if(option_install_packages==1){
  install.packages('devtools')
  devtools::install_git('https://github.com/USDA-ERS/MTED-HARr.git')
  #install package hash
}

require(HARr)


list_simulation_names=c(
  "01Ref",
  "11SecAI",
  "12Aug",
  "13SecNAI",
  "14World",
  "15China",
  "16LowSk",
  "17HiSk"
  #"18AISecW"         #I don't think I'm going to use this simulation
)

library(hash)
results <- hash()
for (simulation in list_simulation_names)
{
results[[simulation]] = read_SL4(paste("Results/",simulation,".sl4",sep=""))
}

EV=as.data.frame(cbind(
  Ref01 <- results[["01Ref"]]$EV,
  SecAI11 <-results[["11SecAI"]]$EV
))
EV
