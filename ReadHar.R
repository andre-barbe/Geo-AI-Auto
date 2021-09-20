#This file does everything for the project: downloading data, manipulating it, creating graphs (or calls the files that do)

#Clear variables
#Source: https://www.geeksforgeeks.org/clear-the-console-and-the-environment-in-r-studio/
rm(list=ls())

option_install_packages=0 #This part only needs to be run once, to install the relevant packages

#Install packages if they aren't installed already
#This doesn't seem to work quite right. Just run it a few times and eventually it should get everything installed. And then turn it off and run the program for "real" to export results
if(option_install_packages==1){
  install.packages('hash')
  install.packages('devtools')
  devtools::install_git('https://github.com/USDA-ERS/MTED-HARr.git')
}

require(HARr)

#Create placeholder hash to store all results in
library(hash)
raw_sl4 <- hash()

#Specify file names of simulations to load results from
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


#Loop over simulation file names and load into the raw_sl4 hash
for (simulation in list_simulation_names)
{
  raw_sl4[[simulation]] = read_SL4(paste("Results/",simulation,".sl4",sep=""))
}

#Specify which variables to export results for
list_var_to_export =c("EV","qgdp","ps")

#Specify which variables are multidimensional, so that they can be treated specially in the nex step
# If dim >1, need to specify here
hash_var_dim <- hash()
hash_var_dim[["ps"]]=2


#Loop through the sl4 has of results, for the specified variables, and putting them in a new (long) df called df_results
for (var in list_var_to_export) 
{ 

  for (simulation_name in list_simulation_names){
  
    #Load the results from the rawsl4 to a temp df
    df_results_temp=as.data.frame(raw_sl4[[simulation_name]][var])
    
    names(df_results_temp)=colnames(df_results_temp)
    
    #Need to deal with variables of dim >1
    if (has.key(var,hash_var_dim)){
      #Reshape from wide to long as documented in https://stackoverflow.com/questions/2185252/reshaping-data-frame-from-wide-to-long-format
      library(reshape2)
      
      #This needs to be installed, as see in https://stackoverflow.com/questions/68416435/rcpp-package-doesnt-include-rcpp-precious-remove
      #install.packages('Rcpp')
      library(Rcpp)
      
      #save row names as a new variable that will be the id variable (melt doesn't use row names automatically as the id variable)
      df_results_temp$com=row.names(df_results_temp)
      
      #melt the wide (dim 2) temp results into a single long (dim 1) results called melted
      df_results_temp = melt(df_results_temp,
                               id.vars = "com", #Names of variables currently along columns, which will be repeated in long
                               variable.name= "region" #Name of variable along columns, each of which will get own entry in long
                               )
      
      #The region variable is of the form ps.USA.TOTAL So I need to strip out the 3 things: ps (var name), the TOTAL, and the .
      df_results_temp$region <- sub(var,"",df_results_temp$region,)
      df_results_temp$region <- sub("TOTAL","",df_results_temp$region)
      df_results_temp$region <- sub(".","",df_results_temp$region,fixed=TRUE) #Fixed=true because . is a special character. If fixed not set to be true, R thinks that I am replacing the first character it finds, with  empty. See https://stackoverflow.com/questions/31518150/gsub-in-r-is-not-replacing-dot
      df_results_temp$region <- sub(".","",df_results_temp$region,fixed=TRUE) #This needs to be done twice as there are two periods and sub only replaces one match
      
    }
    #Now deal with variables of dim =1
    else{
      #give the temp df accurate column names
      names(df_results_temp) <- "value"
      
      #Save row names and regions and clear row names
      df_results_temp$region <- row.names(df_results_temp)
      row.names(df_results_temp)=NULL
      
      #save a blank "com" variable
      df_results_temp$com="NA"
    }
    
    #give the temp df variables for the variable and simulation name
    df_results_temp$simulation_name <- simulation_name
    df_results_temp$var_name <- var
    
    #create the final df if it does not exist
    if (simulation_name==list_simulation_names[1] & var==list_var_to_export[[1]]) df_results=df_results_temp
    
    #or merge the temp df into the final df if it already exists
    else df_results=rbind.data.frame(df_results,df_results_temp)
  }
}
df_results_temp=NULL #unload variables that I am no longer using
hash_var_dim=NULL

#Next step is to drop results that I won't use

#Next step is to create a table of results (not done yet)