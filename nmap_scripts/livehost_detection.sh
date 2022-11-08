#!/bin/bash
 
# COLOURS
 
red='\033[31m'
red_bg='\033[41m'
green='\033[92m'
green_bg='\033[42m'
yellow='\033[33m'
yellow_bg='\033[43m'
blue='\033[34m'
blue_bg='\033[44m'
magenta='\033[95m'
reset='\033[0m'
bold=$(tput bold)
normal=$(tput sgr0)
 
 
# Before running the script, make sure you make a file containing the IPs, Domains or IP ranges in a list form. Make sure one IP is mentioned per line.
 
# The field below represents the selection of the file to be passed through the nmap command. Give the complete location of the file containing the IPs, Domain names or range of IPs. 
 
echo -ne "${green} \aPlease give the location of the file containing IP addresses or domain names : ${reset}"
read -re target_host_file
 
#The field below asks for the location you want, for the outputs of the nnmap command.
echo -ne "${green} \aPlease give the Output location for the Nmap results (ex: /tmp ) : ${reset}"
read -re nmap_output
 
mkdir "$nmap_output"/nmap_outputs
 
outputs="$nmap_output"/nmap_outputs
livehosts=live_hosts.txt
downhosts=down_hosts.txt
logfile=logfile.txt
dt=$(date) 
 
#The following field just displays what the command is doing in the background:
 
echo -e "${blue_bg}                                                                                                                                                                                                                                           ${expand_bg}"
 
echo -e "${blue_bg}-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------${expand_bg}"
 
echo -e "${blue_bg}                                                  Discovering Hosts [ -v -n -sn]                                                                                                                                                           ${expand_bg}"
echo -e "${blue_bg}                                         Host Discovering process is running Please wait....                                                                                                                                               ${expand_bg}"
 
echo -e "${blue_bg}-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------${expand_bg}"
 
echo -e "${blue_bg}                                                                                                                                                                                                                                           ${expand_bg}${reset}"
 
# From the field below, we are going to start approaching the target. The following is going to be our first attempt to find out the live hosts/ips in the network of our target.
# First we are going to hit the target with basic nmap command and save the results in the designated directory we defined earlier for the output of our tests.
# IPs that are live will be saved in the file named "livehosts.txt" and the IPs which are yet not confirmed to be live will be saved in the file named "downhosts.txt"
 
nmap -v -n -sn -iL "$target_host_file" -oA "$outputs"/nmap_out1 2>> "$outputs"/"$logfile" &> /dev/null
cat "$outputs"/nmap_out1.gnmap | grep Up | cut -f 2 -d " " > "$outputs"/"$livehosts" 2>> "$outputs"/"$logfile" 
cat "$outputs"/nmap_out1.gnmap | grep Down | cut -f 2 -d " " > "$outputs"/"$downhosts" 2>> "$outputs"/"$logfile" 
  
# The first test for finding the live hosts in the network is complete now. 
 
echo -e "                                                                                                                                                                                                                                              "
echo -e "${green} \aTEST 1 IS COMPLETE...                                                                                                                                                                                                                      ${reset}"
echo -e "                                                                                                                                                                                                                                              "
echo -e "${yellow} Saving the results of Test 1 and approaching the downed Hosts for the 2nd Test!!                                                                                                                                                    ${reset} "
 
echo -e "                                                                                                                                                                                                                                              "
 
 
# In the next step, we will try to find a few more IPs that can be live by approaching them at their top 20 tcp ports with a Synchronization (SYN) Packet to see if they give any response or not.
 
 
echo -e "${blue_bg}                                                                                                                                                                                                                                           ${expand_bg}"
echo -e "${blue_bg}-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------${expand_bg}"
 
echo -e "${blue_bg}   Targetting the${red} DOWNED HOSTS${reset}\e[0;104m with top 20 TCP ports                                                                                                                                                                                       ${expand_bg}"
 
echo -e "${blue_bg}   [ -v -n -sn -PS21,22,23,25,53,80,110,111,135,139,143,443,445,993,995,1723,3306,3389,5900,8080 ]                                                                                                                                         ${expand_bg}"    
 
echo -e "${blue_bg} ${yellow}  Sending Synchronization (SYN) packets to the Hosts! Please wait...${reset}\e[0;104m                                                                                                                                                                      ${expand_bg}"
 
echo -e "${blue_bg}-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------${expand_bg}"
 
echo -e "${blue_bg}                                                                                                                                                                                                                                           ${expand_bg}${reset}"
 
 
nmap -v -n -sn -PS21,22,23,25,53,80,110,111,135,139,143,443,445,993,995,1723,3306,3389,5900,8080 -iL "$outputs"/"$downhosts" -oA "$outputs"/nmap_out2 2>> "$outputs"/"$logfile" &> /dev/null
 
# Now we are going to update the results to our "livehosts.txt" and "downhosts.txt" files.
 
cat "$outputs"/nmap_out2.gnmap | grep Up | cut -f 2 -d " " >> "$outputs"/"$livehosts" 2>> "$outputs"/"$logfile" 
cat "$outputs"/nmap_out2.gnmap | grep Down | cut -f 2 -d " " > "$outputs"/"$downhosts" 2>> "$outputs"/"$logfile" 
 
# It will update the "livehosts.txt" file with the newly found live IPs and the rest IPs that are still down will be updated in the "downhosts.txt" file. 
# The second test for finding the live hosts in the network is complete now. 
 
 
echo -e "                                                                                                                                                                                                                                              "
 
echo -e "${green} \aTEST 2 IS COMPLETE...                                                                                                                                                                                                                      ${reset}"
 
echo -e "                                                                                                                                                                                                                                              "
 
echo -e "${yellow} Saving the results of Test 2 and approaching the downed Hosts for the 3rd Test!!                                                                                                                                                    ${reset} "
 
echo -e "                                                                                                                                                                                                                                              " 
 
 
echo -e "${blue_bg}                                                                                                                                                                                                                                           ${expand_bg}"
 
echo -e "${blue_bg}-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------${expand_bg}"
 
echo -e "${blue_bg}   Targetting the${red} DOWNED HOSTS${reset}\e[0;104m again with top 20 TCP ports                                                                                                                                                                                 ${expand_bg}"
 
echo -e "${blue_bg}   [ -v -n -sn -PA21,22,23,25,53,80,110,111,135,139,143,443,445,993,995,1723,3306,3389,5900,8080  ]                                                                                                                                        ${expand_bg}"    
 
echo -e "${blue_bg} ${yellow}  Sending Acknowledgement (ACK) packets to the Hosts! Please wait...${reset}\e[0;104m                                                                                                                                                                      ${expand_bg}"
 
echo -e "${blue_bg}-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------${expand_bg}"
 
echo -e "${blue_bg}                                                                                                                                                                                                                                           ${expand_bg}${reset}"
 
 
# In the 3rd try, we're going to approach the Downed IPs at their top 20 tcp ports with an Acknowledgement (ACK) packet to see if they respond to it or not.
# If they give any response, it means they are live and if they don't respond we'll finally accept the fact that they may not be live.
 
 
nmap -v -n -sn -PA21,22,23,25,53,80,110,111,135,139,143,443,445,993,995,1723,3306,3389,5900,8080 -iL "$outputs"/"$downhosts" -oA "$outputs"/nmap_out3 2>> "$outputs"/"$logfile" &> /dev/null
 
# Now we are going to update the results to our "livehosts.txt" and "nmap_down.txt" files again and see if there might be any change or not.
 
cat "$outputs"/nmap_out3.gnmap | grep Up | cut -f 2 -d " " >> "$outputs"/"$livehosts" 2>> "$outputs"/"$logfile" 
cat "$outputs"/nmap_out3.gnmap | grep Down | cut -f 2 -d " " > "$outputs"/"$downhosts" 2>> "$outputs"/"$logfile" 
 
 
 
 
echo -e "                                                                                                                                                                                                                                              " 
echo -e "${green} \aTEST 3 IS COMPLETE...                                                                                                                                                                                                                      ${reset}"
 
echo -e "                                                                                                                                                                                                                                              " 
 
 
 
echo -e "${yellow} Saving the results of Test 3 and approaching the downed Hosts for the 4th Test!!                                                                                                                                                    ${reset} "
 
echo -e "                                                                                                                                                                                                                                              " 
 
 
echo -e "${blue_bg}                                                                                                                                                                                                                                           ${expand_bg}"
 
echo -e "${blue_bg}-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------${expand_bg}"
 
echo -e "${blue_bg}   Targetting the${red} DOWNED HOSTS${reset}\e[0;104m again with top 10 UDP ports                                                                                                                                                                                 ${expand_bg}"
 
echo -e "${blue_bg}   [ -v -sU -p 631,161,137,123,138,1434,445,135,67,53 ]                                                                                                                                                                                    ${expand_bg}"    
 
echo -e "${blue_bg} ${yellow}  Sending UDP packets to the Hosts! Please wait...${reset}\e[0;104m                                                                                                                                                                                        ${expand_bg}"
 
echo -e "${blue_bg}-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------${expand_bg}"
 
echo -e "${blue_bg}                                                                                                                                                                                                                                           ${expand_bg}${reset}"
 
 
# In the 4th try, we are going to approach the Downed IPs with the top 10 UDP ports to see if any service is running at that or not!!
# It is going to be our last test to see if any IP is responding, i.e. it is live or not. After this test if the IP don't respond to anything, we'll assume that the IP is not live.
 
nmap -v -sU -p 631,161,137,123,138,1434,445,135,67,53 -iL "$outputs"/"$downhosts" -oA "$outputs"/nmap_out4 2>> "$outputs"/"$logfile" &> /dev/null
 
cat "$outputs"/nmap_out4.gnmap | grep Up | cut -f 2 -d " " >> "$outputs"/"$livehosts" 2>> "$outputs"/"$logfile" 
cat "$outputs"/nmap_out4.gnmap | grep Down | cut -f 2 -d " " > "$outputs"/"$downhosts" 2>> "$outputs"/"$logfile" 
 
 
 
echo -e "                                                                                                                                                                                                                                              " 
echo -e "${green} \aTEST 4 IS COMPLETE...                                                                                                                                                                                                                      ${reset}"
 
echo -e "                                                                                                                                                                                                                                              " 
 
 
 
 
echo -e "${green_bg}                                                                                                                                                                                                                                           ${expand_bg}"
echo -e "${green_bg}*******************************************************************************************************************************************************************************************************************************************${expand_bg}"
 
echo -e "${green_bg} PROCESS                                                                                                                                                                                                                                   ${expand_bg}"
echo -e "${green_bg}               IS                                                                                                                                                                                                                          ${expand_bg}${reset}"
 
echo -e "${green_bg}                         DONE!!                                                                                                                                                                                                            ${expand_bg}${reset}"
echo -e "${green_bg}*******************************************************************************************************************************************************************************************************************************************${expand_bg}${reset}"
 
echo -e "${green_bg}                                                                                                                                                                                                                                           ${expand_bg}${reset}"
 
 
echo -e "                                                                                                                                                                                                                                              " 
echo -e "$dt"
 
echo -e "                                                                                                                                                                                                                                              " 
echo -e  "${red_bg}${bold}Here is the list of live Hosts${normal}${reset}"
 
echo -e "                                                                                                                                                                                                                                              " 
cat -n "$outputs"/"$livehosts"
 
echo -e "                                                                                                                                                                                                                                              " 
 
echo -e "${blue} All the results are saved in ${nmap_output}${reset} "
echo -e "${magenta} Check for the Up and Down IPs in the given location in files 'livehosts.txt' and 'downhosts.txt' respectively!! ${reset}  "
echo -e "${green} Thanks for using this script...  ${reset} "
 
echo -e "                                                                                                                                                                                                                                              " 
 
# Now that the Process is done, you'll find the list of live hosts in the directory you mentioned for saving the Output, named "livehosts.txt" and also you'll find all the files containing the result of all the processes that took place while this script was running!!
# After all these tests, we are going to assume that the IPs that are not in the list are down and focus on the live hosts.

