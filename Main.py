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
    "file gtapPARM = GTAP_Data_Files/default.prm;\n",
    "Verbal Description =\n",
    "none;\n",
]

#Define the dictionary of simulations. It is of the form:
# key (Sim code name):
# Entry (Sim cmf stuff, such as solution file location and the shocks
simulation_dictionary={
    '01Ref' :
        ["Updated file gtapDATA = Results/01Ref.upd;\n",
        "Solution file = Results/01Ref;\n",
        "swap qo(\"capital\",REG) = Expand(\"capital\",REG);\n",
        "shock qo(all_lab , \"usa\") = uniform 50;\n"],
    '11SecAI':
        ["Updated file gtapDATA = Results/11SecAI.upd;\n",
         "Solution file = Results/11SecAI;\n",
         "swap qo(\"capital\",REG) = Expand(\"capital\",REG);\n",
         "shock afeall(all_lab, ai_comm, \"usa\") = uniform 50;\n"],
    '12Aug':
        ["Updated file gtapDATA = Results/12Aug.upd;\n",
         "Solution file = Results/12Aug;\n",
         "swap qo(\"capital\",REG) = Expand(\"capital\",REG);\n",
         "shock afeall(all_lab, prod_comm, \"usa\") = uniform 50;\n"],
    '13SecNAI':
        ["Updated file gtapDATA = Results/13SecNAI.upd;\n",
         "Solution file = Results/13SecNAI;\n",
         "swap qo(\"capital\",REG) = Expand(\"capital\",REG);\n",
         "shock afeall(all_lab, nonai_comm, \"usa\") = uniform 50;\n"],
    '14World':
        ["Updated file gtapDATA = Results/14World.upd;\n",
         "Solution file = Results/14World;\n",
         "swap qo(\"capital\",REG) = Expand(\"capital\",REG);\n",
         "shock qo(all_lab, reg) = uniform 50;\n"],
    '15China':
        ["Updated file gtapDATA = Results/15China.upd;\n",
         "Solution file = Results/15China;\n",
         "swap qo(\"capital\",REG) = Expand(\"capital\",REG);\n",
         "shock qo(all_lab, \"china\") = uniform 50;\n"],
    '16LowSk':
        ["Updated file gtapDATA = Results/16LowSk.upd;\n",
         "Solution file = Results/16LowSk;\n",
         "swap qo(\"capital\",REG) = Expand(\"capital\",REG);\n",
         "shock qo(lo_lab, \"usa\") = uniform 50;\n"],
    '17HiSk':
        ["Updated file gtapDATA = Results/17HiSk.upd;\n",
         "Solution file = Results/17HiSk;\n",
         "swap qo(\"capital\",REG) = Expand(\"capital\",REG);\n",
         "shock qo(hi_lab, \"usa\") = uniform 50;\n"],
    '18AiSecW': #Increase producivity of AI sectors, but in entire world (not just US as in 11)
        ["Updated file gtapDATA = Results/17HiSk.upd;\n",
         "Solution file = Results/17HiSk;\n",
         "swap qo(\"capital\",REG) = Expand(\"capital\",REG);\n",
         "shock afeall(all_lab, ai_comm, reg) = uniform 50;\n"]
}

#Loop to create the cmf file and run it
for simulation_name in simulation_dictionary.keys():
    cmf_file  = open("Control_Files/{0}.cmf".format(simulation_name), "w")
    cmf_file.writelines(lines_common + simulation_dictionary[simulation_name])
    cmf_file.close()
    subprocess.call("GTAP_Model_Files/GTAPU.exe -cmf Control_Files/{0}.cmf".format(simulation_name))