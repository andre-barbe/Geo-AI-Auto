#This file does everything for the project: downloading data, manipulating it, creating graphs (or calls the files that do)

#Clear variables
#Source: https://www.geeksforgeeks.org/clear-the-console-and-the-environment-in-r-studio/
rm(list=ls())

option_install_packages=0 #This part only needs to be run once, to install the relevant packages
  #This doesn't seem to work quite right. Just run it a few times and eventually it should get everything installed. And then turn it off and run the program for "real" to export results

if(option_install_packages==1){
  install.packages('hash')
  install.packages('devtools')
  devtools::install_git('https://github.com/USDA-ERS/MTED-HARr.git')
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
raw_sl4 <- hash()
for (simulation in list_simulation_names)
{
  raw_sl4[[simulation]] = read_SL4(paste("Results/",simulation,".sl4",sep=""))
}

results <- hash()
for (var in c("EV","qgdp"))
{ #list of variables to export 
  if (length(list_simulation_names)!=8) {stop("Error: Wrong length of simulation list")} #The cbind has 8 terms, assuming that there are 8 simulations. I would have used a loop but couldn't figure out how
  results[[var]] =
    cbind(as.data.frame(raw_sl4[[list_simulation_names[1]]][var]),
                         as.data.frame(raw_sl4[[list_simulation_names[2]]][var]),
                         as.data.frame(raw_sl4[[list_simulation_names[3]]][var]),
                         as.data.frame(raw_sl4[[list_simulation_names[4]]][var]),
                         as.data.frame(raw_sl4[[list_simulation_names[5]]][var]),
                         as.data.frame(raw_sl4[[list_simulation_names[6]]][var]),
                         as.data.frame(raw_sl4[[list_simulation_names[7]]][var]),
                         as.data.frame(raw_sl4[[list_simulation_names[8]]][var])
    )
  names(results[[var]]) <- list_simulation_names
}
df_EV=results[["EV"]]