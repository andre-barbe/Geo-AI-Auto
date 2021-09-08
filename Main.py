__author__ = "Andre Barbe"
__created__ = "2021-09-06"
# This file is the main one, it automates the running of the GTAP files

import subprocess

# Create cmf_file for each simulation
# Instructions on how to write a cmf file are available here:
# https://www.kite.com/python/answers/how-to-write-to-a-file-in-python

#Define the lines in common to all cmf files
lines_common=[
    "!Define AI and non-AI Sectors\n",
    "XSET AI_COMM # AI related comms # (OthServices, CMN, OBS, Transport) ;\n",
    "XSUBSET AI_COMM is subset of TRAD_COMM ;\n",
    "XSET NONAI_COMM = TRAD_COMM - AI_COMM ;\n",
    "\n",
    "!Define Labor, High, and Low\n",
    "!Off_Mgr_Pros is ILO category 1\n",
    "!Tech_AsPros is ILO 2 and 3\n",
    "!Clerks is ILO 4\n",
    "!Service_Shop is ILO 5\n",
    "!Ag_OthLowSk is ILO 6-9\n",
    "XSET HI_LAB # High Skilled Labor # (Off_Mgr_Pros, Tech_AsPros) ;\n",
    "XSUBSET HI_LAB is subset of ENDW_COMM ;\n",
    "XSET LO_LAB # Low Skilled Labor # (Clerks, Service_Shop, Ag_OthLowSk) ;\n",
    "XSUBSET LO_LAB is subset of ENDW_COMM ;\n",
    "XSET ALL_LAB = HI_LAB + LO_LAB ;\n",
    "XSUBSET ALL_LAB is subset of ENDW_COMM ;\n",
    "!@ end of CMFSTART part\n",
    "\n",
    "aux files = GTAP_Model_Files/GTAPU;\n",
    "file gtapSETS = GTAP_Data_Files/sets.har;\n",
    "file gtapDATA = GTAP_Data_Files/basedata.har;\n",
    "\n",
    "Method = Gragg;\n",
    "Steps = 2 4 6;\n",
    "automatic accuracy = yes;\n",
    "accuracy figures = 4;\n",
    "accuracy percent = 99;\n",
    "minimum subinterval length =  1.0E-0003;\n",
    "minimum subinterval fails = stop;\n",
    "accuracy criterion = Data;\n",
    "subintervals = 2;\n",
    "exogenous\n",
    "          pop\n",
    "          psaveslack pfactwld\n",
    "          profitslack incomeslack endwslack\n",
    "          cgdslack tradslack\n",
    "          ams atm atf ats atd\n",
    "          aosec aoreg avasec avareg\n",
    "          afcom afsec afreg afecom afesec afereg\n",
    "          aoall afall afeall\n",
    "          au dppriv dpgov dpsave\n",
    "          to tp tm tms tx txs\n",
    "          qo(ENDW_COMM,REG)\n",
    "          atall avaall tf tfd tfm tgd tpd tgm tpm;\n",
    "Rest Endogenous ;\n",
    "\n",
]

#Define the dictionary of simulations. It is of the form:
# key (Sim code name):
# Entry (Sim cmf stuff, such as solution file location and the shocks
simulation_dictionary={
    '01Ref' :
    ["Updated file gtapDATA = Results/01Ref.upd;\n",
       "Solution file = Results/01Ref;\n",
      "file gtapPARM = GTAP_Data_Files/default.prm;\n",
      "Verbal Description =\n",
      "1 Reference case. Increase supply of all 5 types of labor in USA;\n",
      "\n",
      "swap qo(\"capital\",REG) = Expand(\"capital\",REG);\n",
      "shock qo(all_lab , \"usa\") = uniform 50;\n"],
    '02Test':
        ["Updated file gtapDATA = Results/02Test.upd;\n",
         "Solution file = Results/02Test;\n",
         "file gtapPARM = GTAP_Data_Files/default.prm;\n",
         "Verbal Description =\n",
         "2 Test case. Increase supply of all 5 types of labor in USA;\n",
         "\n",
         "swap qo(\"capital\",REG) = Expand(\"capital\",REG);\n",
         "shock qo(all_lab , \"usa\") = uniform 50;\n"]
}

#Loop to create the cmf file and run it
for simulation_name in simulation_dictionary.keys():
    cmf_file  = open("Control_Files/{0}.cmf".format(simulation_name), "w")
    cmf_file.writelines(lines_common + simulation_dictionary[simulation_name])
    cmf_file.close()
    subprocess.call("GTAP_Model_Files/GTAPU.exe -cmf Control_Files/{0}.cmf".format(simulation_name))
