#This file exports the RunGTAP results, after that has been run


rm(list=ls())
  #Clear variables
  #Source: https://www.geeksforgeeks.org/clear-the-console-and-the-environment-in-r-studio/

#list_of_simulations_to_sltoht=list("01Ref","11SecAI")
list_of_simulations_to_sltoht=list("01Ref")

library(stringr)
  #necessary for function "word"


#Export results from sl4 to csv
  for (simulation_to_sltoht in list_of_simulations_to_sltoht)
  {
    shell(paste("sltoht -ses SaveSims/",simulation_to_sltoht,sep=""))
      #Runs sltoht on a single .sl4 results files
      #Sltoht command to export results is sltoht -ses 01Ref
      #NTS: Don't change wd to SaveSims. That does so for Rstudio and you will have to exit and restart R studio. Instead just put the folder in the shell call above
      #Shell command explained in https://www.r-bloggers.com/2020/01/working-with-windows-cmd-system-commands-in-r/
    
    
    #Load CSV results into R
    file_sim_csv=paste("SaveSims/",simulation_to_sltoht,".csv",sep="")
    max_no_col=max(count.fields(file_sim_csv, sep = ','),na.rm=T)
      #counts the max number of fields in the file
      #see https://sites.psu.edu/biomonika/2017/09/08/reading-text-files-with-variable-number-of-columns-in-r/
      #na.rm is necessary for my file because otherwise it says the max is na
    data_frame_sim_csv=read.csv(file_sim_csv,
               header=F,
               col.names = paste0("V",seq_len(max_no_col)),
                                  #This is necessary as the csv file has different columns on each row
                                  #see https://stackoverflow.com/questions/18922493/how-can-you-read-a-csv-file-in-r-with-different-number-of-columns
               quote = ""
                #This is necessary but I'm not sure why. Without it I get an error. Stack Overflow says that this is due to the quote character in my .csv file, but I don't see it there
                #See https://stackoverflow.com/questions/30148254/r-read-table-with-quotation-marks
                )
    
    #Clean and format dataframe for the simulation
      list_of_regions=list("USA",            
                           "China",          
                           "xAmericas",      
                           "AdvancedAsia",   
                           "SouthAsia",      
                           "xAsia",          
                           "WEuroCndANZ",    
                           "MENA",           
                           "SSA",            
                           "RestofWorld")
      
      list_of_sectors=list( "Agriculture" ,
                            "Extraction"  ,
                            "LightMnfc"   ,
                            "HeavyMnfc"   ,
                            "Energy"      ,
                            "CMN"         ,
                            "OBS"         ,
                            "Trade"       ,
                            "Transport"   ,
                            "OthServices" 
      )
      
      # Variable pfe(ENDW_COMM:PROD_COMM:REG) of size 8x11x10
      

      #get dimension of each variable
        data_frame_sim_csv$dim=NA
        data_frame_sim_csv$dim[grepl("of size [0-9]+$",data_frame_sim_csv$V1)]=1
          #takes value of true if variable is of dimension 1
          #https://www.rdocumentation.org/packages/stringr/versions/1.4.0/topics/str_match
          #Regex cheatsheet: https://www.keycdn.com/support/regex-cheatsheet
          #grepl defined in https://www.rdocumentation.org/packages/base/versions/3.6.2/topics/grep
        data_frame_sim_csv$dim[grepl("of size [0-9]+x[0-9]+$",data_frame_sim_csv$V1)]=2
        data_frame_sim_csv$dim[grepl("of size [0-9]+x[0-9]+x[0-9]+$",data_frame_sim_csv$V1)]=3
        
        #Define variable name
          data_frame_sim_csv$var_name[!is.na(data_frame_sim_csv$dim)]=word(data_frame_sim_csv$V1[!is.na(data_frame_sim_csv$dim)],4)
          #variables are rows that are not NA
          #variable name is the 4th word on that row
          #https://www.rdocumentation.org/packages/stringr/versions/1.4.0/topics/word
        
      
      #Loop over variables of dim 1
          list_of_names_of_variables_of_dim_1 = data_frame_sim_csv$var_name[data_frame_sim_csv$dim==1]
          for (variable in list_of_names_of_variables_of_dim_1) {
            rownumber_variable= as.integer(rownames(data_frame_sim_csv)[data_frame_sim_csv$var_name==variable])
              #find row of the variable
              #https://stackoverflow.com/questions/2370515/how-to-get-row-index-number-in-r
            rownumber_start=rownumber_variable+1
            rownumber_start=rownumber_variable+1
            
            
          }

      
      
    
  }


#Convert results in R data frame

#Merge results from other simulations
