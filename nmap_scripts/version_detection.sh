#!/bin/bash
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
echo -ne "${yellow}\a Please give the location of the file containing live hosts : ${reset}"
read -re target_host_file
# ------------------------------------------------------------------
#The field below asks for the location you want, for the outputs of the nnmap command.
# ------------------------------------------------------------------
 
echo -ne "${yellow}\a Please give the Output location for the Nmap results (Default: /tmp) : ${reset}"
read -re nmap_output
nmap_port_output="${nmap_port_output:=/tmp}"
 
# ------------------------------------------------------------------
# Creating a Output folder
# ------------------------------------------------------------------ 
mkdir "$nmap_port_output"/nmap_port_outputs 2> /dev/null

# ------------------------------------------------------------------ 
# Defined variables
# ------------------------------------------------------------------ 
nmap_port_output="${nmap_port_output:=/tmp}"
outputs="$nmap_port_output"/nmap_port_outputs
nmapoutputs=nmapoutputs.gnmap
standard=open_ports_standard.txt
fornmap=open_ports_for_nmap.txt
nmapsV=nmap_sV.txt 
dt=$(date)
 
# ------------------------------------------------------------------
#The following field just displays what the command is doing in the background:
# ------------------------------------------------------------------
echo -e " "
echo -e "  "
echo -e "${cyan}====================================[ ${yellow}Discovering open ports${reset}${cyan} ]=====================================${reset}"
echo -e "${green}\a nmap [ -Pn -n -sT  ] ${normal}${reset}" 
echo -e "${green}\a Please wait...${normal}${reset}"
echo -e "${cyan}===================================================================================================${reset}"
echo -e " "

# From the field below, we are going to start approaching the target. The following is going to be our first attempt to find out the open ports in the network of our target.
# We are going to hit the target with basic nmap command and save the results in the designated directory we defined earlier for the output of our tests.
# Open ports of live hosts will be saved in the file named "open-ports.txt".
  
nmap -Pn -n -sT -iL "$target_host_file" -oG "$outputs"/"$nmapoutputs" > /dev/null
 
echo -e "${yellow} Port scanning is completed!! ${reset} " | notify -silent
echo -e " "
echo -e "${cyan}=====================================[ ${yellow}open_ports_standard.txt${reset}${cyan} ]===================================${reset}"
echo -e "${green}\a The result of open ports which you can use in other tools is save in this location:
 ${bold}${red}"$outputs"/"$standard" ${normal}${reset}" 
echo -e "${green}\a Please wait...${normal}${reset}"
echo -e "${cyan}===================================================================================================${reset}"
 
grep "open" "$outputs"/"$nmapoutputs" | while read -r line
 
do 
 
    ip=$(echo $line | grep -oP '(?<=^Host:) (\d{1,3}\.){3}\d{1,3}')
    echo "$line" | grep -oP '(?<=\tPorts: )[^\t]*\t' | sed -e 's/, /\n/g' | cut -d/ -f 1 | sed -e "s/^/$ip:/g"
 
done > "$outputs"/"$standard"
 
echo -e "                                                                                                                                      "
echo -e "${cyan}=====================================[ ${yellow}open_ports_for_nmap.txt${reset}${cyan} ]===================================${reset}"
echo -e "${green}\a The result of open ports which you can use in nmap for further scanning is save in this location:
 ${bold}${red}"$outputs"/"$fornmap" ${normal}${reset}" 
echo -e "${green}\a Please wait...${reset}"
echo -e "${cyan}===================================================================================================${reset}"
 
grep "open" "$outputs"/"$nmapoutputs" | while read -r line
 
do 
 
    ip=$(echo $line | grep -oP '(?<=^Host:) (\d{1,3}\.){3}\d{1,3}')
    ports=$(echo "$line" | grep -oP '(?<=\tPorts: )[^\t]*\t' | sed -e 's/, /\n/g' | cut -d/ -f 1 | tr "\n" "," | sed -e 's/,$//g' )
    echo $ip:$ports
 
done > "$outputs"/"$fornmap"
 

echo -e " "
echo -e "${yellow} Moving on to the version detection... ${reset} " |  notify -silent
echo -e "                                                                                                                                       "
echo -e "${cyan}===================================[ ${yellow}Open ports service scanning${reset}${cyan} ]=================================${reset}"
echo -e "${green}\a nmap [ -Pn -sT -sV -sC -A  ] ${normal}${reset}" 
echo -e "${green}\a Please wait...${normal}${reset}"
echo -e "${cyan}===================================================================================================${reset}"
 
cat  "$outputs"/"$fornmap"  | while read -r line
 
do
 
    ip=$(echo $line | cut -d: -f 1 )
    ports=$(echo $line | cut -d: -f 2 )
 
    nmap -Pn -sT -sV -sC -A -O $ip -p $ports 
 
done > "$outputs"/"$nmapsV"
 
echo -e "                                                                                                                                       "
echo -e "${cyan}==========================================[ ${yellow}nmap_sV.txt${reset}${cyan} ]=========================================${reset}"
echo -e "${green}\a The result of open ports service scanning is save in this location:
 ${bold}${red}"$outputs"/"$nmapsV" ${normal}${reset}"| notify -silent
echo -e "${green}\a Please wait...${normal}${reset}"
echo -e "${cyan}==================================================================================================${reset}"
echo -e " "
echo -e "${green}${bold}                     Scan Complete!! ${reset}${normal} " | notify -silent
echo -e " "
 
duration=$SECONDS
echo -e "${yellow}Elapsed Time: $(($duration / 60)) minutes and $(($duration % 60)) seconds. ${reset}"
echo -e " "
echo -e "${cyan}==================================[ ${yellow}Location where result is save${reset}${cyan} ]==================================${reset}"
echo -e "${magenta}The result of Discovering open ports is save in this location:
${reset}${bold}${red}"$outputs"/"$nmapoutputs" ${normal}${reset}"
echo -e " "
echo -e "${magenta}The result of open ports which you can use in other tools is save in this location:
${bold}${red}"$outputs"/"$standard" ${normal}${reset}"
echo -e " "
echo -e "${magenta}The result of open ports which you can use in nmap for further scanning is save in this location:
${bold}${red}"$outputs"/"$fornmap" ${normal}${reset}"
echo -e " "
echo -e "${magenta}The result of open ports service scanning is save in this location:
${bold}${red}"$outputs"/"$nmapsV" ${normal}${reset}"
echo -e "${cyan}===================================================================================================${reset}"
