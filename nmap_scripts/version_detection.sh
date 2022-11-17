#!bin/bash
figlet "ArmourInfosec"
SECONDS=0
# ------------------------------------------------------------------
# COLOURS
# ------------------------------------------------------------------
 
red='\033[31m'
red_bg='\033[41m'
green='\033[92m'
yellow='\033[33m'
blue='\033[34m'
magenta='\033[95m'
reset='\033[0m'
black='\033[30m'
cyan='\033[96m'
bold=$(tput bold)
normal=$(tput sgr0)
 
# ------------------------------------------------------------------ 
# Requirements:
# ------------------------------------------------------------------
# Nmap 
# Notify
 
# ------------------------------------------------------------------
# Before running the script, make sure you either run our previous script for finding live hosts or make a file manually of live host.
# The field below represents the selection of the file to be passed through the nmap command. Give the complete location of the file containing the Live Hosts/IPs. 
# ------------------------------------------------------------------
   
echo -e " " 
echo -ne "${yellow}${bold} \aPlease give the location of the file containing live hosts : ${reset}"
read -re target_host_file
# ------------------------------------------------------------------
#The field below asks for the location you want, for the outputs of the nnmap command.
# ------------------------------------------------------------------
 
echo -ne "${yellow}${bold} \aPlease give the Output location for the Nmap results (Default: /tmp) : ${reset}"
read -re nmap_output
 
# ------------------------------------------------------------------ 
# Defined variables
# ------------------------------------------------------------------ 
nmap_output_file="$nmap_output"/nmapoutputs.gnmap
nmap_output="${nmap_output:=/tmp}"
 
# ------------------------------------------------------------------
#The following field just displays what the command is doing in the background:
# ------------------------------------------------------------------
echo -e " "
echo -e "                                                                                                                                       "
echo -e "${cyan}${bold}====================================[ Discovering open ports ]====================================${reset}"
echo -e "${green}${bold} \a  nmap [ -Pn -n -sT  ] ${normal}${reset}" 
echo -e "${green}${bold} \a             Please wait...${normal}${reset}"
echo -e "${cyan}${bold}==================================================================================================${reset}"
echo -e " "

# From the field below, we are going to start approaching the target. The following is going to be our first attempt to find out the open ports in the network of our target.
# We are going to hit the target with basic nmap command and save the results in the designated directory we defined earlier for the output of our tests.
# Open ports of live hosts will be saved in the file named "open-ports.txt".
 
 
nmap -Pn -n -sT -iL "$target_host_file" -oG "$nmap_output"/nmapoutputs.gnmap > /dev/null
 

echo -e " "
echo -e "${green}${bold} Port scanning is completed!! ${reset} " | notify -silent
echo -e " "
echo -e "                                                                                                                                       "
echo -e "${cyan}${bold}====================================[ open_ports_standard.txt ]====================================${reset}"
echo -e "${green}${bold} \a  Saving the result of open ports which you can use in other tools in "open_ports_standard.txt" ${normal}${reset}" 
echo -e "${green}${bold} \a             Please wait...${normal}${reset}"
echo -e "${cyan}${bold}==================================================================================================${reset}"
 
grep "open" $nmap_output_file | while read -r line
 
do 
 
    ip=$(echo $line | grep -oP '(?<=^Host:) (\d{1,3}\.){3}\d{1,3}')
    echo "$line" | grep -oP '(?<=\tPorts: )[^\t]*\t' | sed -e 's/, /\n/g' | cut -d/ -f 1 | sed -e "s/^/$ip:/g"
 
done > "$nmap_output"/open_ports_standard.txt
 
echo -e " "
echo -e "                                                                                                                                       "
echo -e "${cyan}${bold}====================================[ open-ports-for-nmap.txt]====================================${reset}"
echo -e "${green}${bold} \a  Saving the result of open ports for further nmap use in "open-ports-for-nmap.txt" ${normal}${reset}" 
echo -e "${green}${bold} \a             Please wait...${normal}${reset}"
echo -e "${cyan}${bold}==================================================================================================${reset}"
 
 
 
grep "open" $nmap_output_file | while read -r line
 
do 
 
    ip=$(echo $line | grep -oP '(?<=^Host:) (\d{1,3}\.){3}\d{1,3}')
    ports=$(echo "$line" | grep -oP '(?<=\tPorts: )[^\t]*\t' | sed -e 's/, /\n/g' | cut -d/ -f 1 | tr "\n" "," )
    echo $ip:$ports
 
done > "$nmap_output"/open-ports-for-nmap.txt
 

echo -e " "
echo -e "${red} Moving on to the version detection... ${reset} " |  notify -silent
echo -e " "
echo -e "                                                                                                                                       "
echo -e "${cyan}${bold}==================================[ Open ports service scanning ]==================================${reset}"
echo -e "${green}${bold} \a      nmap [ -Pn -sT -sV -sC -A  ] ${normal}${reset}" 
echo -e "${green}${bold} \a             Please wait...${normal}${reset}"
echo -e "${cyan}${bold}==================================================================================================${reset}"
 
cat "$nmap_output"/open-ports-for-nmap.txt | while read -r line
 
do
 
    ip=$(echo $line | cut -d: -f 1 )
    ports=$(echo $line | cut -d: -f 2 )
 
    nmap -Pn -sT -sV -sC -A $ip -p $ports 
 
done > "$nmap_output"/nmap_sV.txt
 
echo -e " "
echo -e "                                                                                                                                       "
echo -e "${cyan}${bold}=========================================[ nmap_sV.txt ]=========================================${reset}"
echo -e "${green}${bold} \a  Saving the result of open ports service scanning in "nmap_sV.txt" ${normal}${reset}" | notify -silent
echo -e "${green}${bold} \a             Please wait...${normal}${reset}"
echo -e "${cyan}${bold}==================================================================================================${reset}"
echo -e " "
echo -e " "
echo -e "${green}${bold}        Scan Complete!! ${reset} " | notify -silent
echo -e " "
 
duration=$SECONDS
echo -e "${red}Elapsed Time: $(($duration / 60)) minutes and $(($duration % 60)) seconds. ${reset}"