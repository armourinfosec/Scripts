#!/bin/bash

# ------------------------------------------------------------------ 
# Requirements:
# ------------------------------------------------------------------
# Nmap 
# Notify

SECONDS=0
SCRIPT_NAME=$0

# ------------------------------------------------------------------
# COLORS
# ------------------------------------------------------------------

red='\033[0;31m'
blue='\033[0;34m'
green='\033[0;32m'
yellow='\033[0;33m'
purple='\033[0;35m'
reset='\033[0m'

# ------------------------------------------------------------------
# Banner
# ------------------------------------------------------------------
function banner(){
echo -e  "    ____      ____     _____            _       __                _           "
echo -e  "   /  _/___  / __/___ / ___/___  ____  | |     / /___ ___________(_)___  _____"
echo -e  "   / // __ \/ /_/ __ \\__ \/ _ \/ ___/  | | /| / / __ \`/ ___/ ___/ / __ \/ ___/"
echo -e  " _/ // / / / __/ /_/ /__/ /  __/ /__   | |/ |/ / /_/ / /  / /  / / /_/ / /    "
echo -e  "/___/_/ /_/_/  \____/____/\___/\___/   |__/|__/\__,_/_/  /_/  /_/\____/_/     "
echo -e  "                                                                              "
echo -e  "  github.com/InfoSecWarrior                                 by @ArmourInfosec "
echo -e  "\n"

}

# ------------------------------------------------------------------
# Print Functions
# ------------------------------------------------------------------

function INFO_PRINT(){

   echo -e ${blue} [" "INFO"  "] ${reset}
}

function WARNING_PRINT(){

  echo -e ${yellow} [WARNING] ${reset}
}

function ERROR_PRINT(){

    echo -e ${red} [ ERROR ] ${reset}
}

function COMMAND_PRINT(){

    echo -e ${green} [COMMAND] ${reset}
}

function NOTIFY_PRINT(){

    echo -e ${purple} [NOTIFY ] ${reset}
}

# ------------------------------------------------------------------
# Usage Help Function
# ------------------------------------------------------------------

function USAGE_HELP()
{
    echo -e "Usage:"
    echo -e "\t $SCRIPT_NAME [flags] \n"
    echo -e "Flags:"
    echo -e "HELP:"
    echo -e "\t -h, --help \t\tShow this help message and exit\n"
    echo -e "TARGET:"
    echo -e "\t -u, --target domain.tld  \tTarget Domain or IP Address"
    echo -e "\t -l, --list ip_list.txt   \tPath to file containing a List of Target Hosts to scan (one per line) \n"
    echo -e "OUTPUT:"
    echo -e "\t -o, --output output/path  \tDefine Output Folder\n"
    echo -e "MODE:"
    echo -e "\t -s, --silent  \t\t\tDisable Print the Banner"
    echo -e "\t -p, --portscan  \t\tPort scan"
    echo -e "\t -v, --versiondetection  \tService Version Detection (Requires root privileges)"

  exit 2
}

# ------------------------------------------------------------------
# Getopt
# ------------------------------------------------------------------

SHORT=u:,l:,o:,s,p,v,h
LONG=target:,list:,output:,silent,portscan,versiondetection,help
PARSED_ARGUMENTS=$(getopt --alternative --quiet --name $SCRIPT_NAME --options $SHORT --longoptions $LONG -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ] || [ "$#" == "0" ]; then
  USAGE_HELP
fi

eval set -- "$PARSED_ARGUMENTS"
unset PARSED_ARGUMENTS

while :
do
  case "$1" in

    '-h' | '--help')

      USAGE_HELP
      shift ;;

    '-u' | '--target')

      TARGET_HOST=$2
      shift 2 ;;
    
    '-l' | '--list')

      TARGET_HOST_LIST=$2
      shift 2 ;;
    
    '-o' | '--output')

      MAIN_OUTPUT_DIR=$2
      shift 2 ;;
    
    '-s' | '--silent')

      SILENT_MODE=true
      shift ;;

    '-p' | '--portscan')

      PORTSCAN=true
      shift ;;

    '-v' | '--versiondetection')

      VERSIONDETECTION=true
      shift ;;

    '--')

      shift
      break ;;

    '*')

      USAGE_HELP ;;

  esac
done


if [[ -z "${TARGET_HOST}" ]] && [[ -z "${TARGET_HOST_LIST}" ]]; then

  echo -e "$(ERROR_PRINT) Target is missing, try using -u <Target Domain or IP Address> / -l <ip_list> "
  echo -e "$(ERROR_PRINT) Please provide any one TARGET Option"
  exit 3

fi

if [[ -n "${TARGET_HOST}" ]] && [[ -n "${TARGET_HOST_LIST}" ]]; then

  echo -e "$(ERROR_PRINT) Multiple Target are provide, try using -u <Target Domain or IP Address> / -l <ip_list> "
  echo -e "$(ERROR_PRINT) Please provide Only one TARGET Option"
  exit 4

fi

if [[ -n "${VERSIONDETECTION}"  ]]; then

  if [[ -z "${PORTSCAN}" ]]; then
    
      echo -e "$(ERROR_PRINT) -p is required for Service Version Detection "

      exit 5
  
  fi

fi

# ------------------------------------------------------------------
# Location for the outputs of the nmap command.
# ------------------------------------------------------------------

MAIN_OUTPUT_DIR="${MAIN_OUTPUT_DIR:=$(pwd)}"
NMAP_OUTPUT_DIR=nmap_outputs

if [[ -d "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR" ]]; then
  
    echo -e "$(ERROR_PRINT) "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR" Directory already Exists Please choose a different location"
    exit 6

fi

mkdir "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR" 2> /dev/null

LIVE_HOSTS_FILE=LIVE-HOSTS.txt
DOWN_HOSTS_FILE=DOWN-HOSTS.txt
LOG_FILE=LOG-FILE.txt
TEMP_DIR=.tmp

mkdir "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$TEMP_DIR" 2>> "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LOG_FILE"

# ------------------------------------------------------------------
# Check Nmap install or Not
# ------------------------------------------------------------------

which nmap &>/dev/null

if [ $? -eq 0 ]; then

    NMAP_INSTALL=true

else

    NMAP_INSTALL=false
    echo -e "$(ERROR_PRINT) Nmap is not install. "
    exit 7

fi

# ------------------------------------------------------------------
# Check notify install or Not
# ------------------------------------------------------------------

which notify &>/dev/null

if [ $? -eq 0 ]; then

    NOTIFY_INSTALL=true

else

    NOTIFY_INSTALL=false

fi

if [[ "${NOTIFY_INSTALL}" = true ]]; then

  echo "$SCRIPT_NAME Starting" | notify -silent &>/dev/null

  if [ $? -eq 0 ]; then

      NOTIFY_CONF=true

  else

      NOTIFY_CONF=false

  fi
  
fi



if [[ -z "${SILENT_MODE}" ]]; then
  
    banner

fi

if [[ "${NOTIFY_INSTALL}" = false ]]; then
  
    echo -e "$(ERROR_PRINT) Notify is not install."

fi

if [[ "${NOTIFY_CONF}" = false ]]; then
  
    echo -e "$(ERROR_PRINT) Notify is not config."

fi


# ------------------------------------------------------------------
# Hosts Discovering nmap function
# ------------------------------------------------------------------

function DISCOVERING_HOSTS_WITH_PING(){


  if [[ -n "${TARGET_HOST}" ]]; then

      nmap -v -n -sn "$TARGET_HOST" -oA "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$TEMP_DIR"/LIVE-HOSTS-TRY-1 2>> "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LOG_FILE" &> /dev/null
  
      cat "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$TEMP_DIR"/LIVE-HOSTS-TRY-1.gnmap | grep Up | cut -f 2 -d " " > "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LIVE_HOSTS_FILE" 2>> "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LOG_FILE"

      cat "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$TEMP_DIR"/LIVE-HOSTS-TRY-1.gnmap | grep Down | cut -f 2 -d " " > "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$DOWN_HOSTS_FILE" 2>> "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LOG_FILE"

  else

      nmap -v -n -sn -iL "$TARGET_HOST_LIST" -oA "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$TEMP_DIR"/LIVE-HOSTS-TRY-1 2>> "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LOG_FILE" &> /dev/null

      cat "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$TEMP_DIR"/LIVE-HOSTS-TRY-1.gnmap | grep Up | cut -f 2 -d " " > "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LIVE_HOSTS_FILE" 2>> "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LOG_FILE"

      cat "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$TEMP_DIR"/LIVE-HOSTS-TRY-1.gnmap | grep Down | cut -f 2 -d " " > "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$DOWN_HOSTS_FILE" 2>> "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LOG_FILE"
  
  fi
        
}

# ------------------------------------------------------------------
# NMAP TCP SYN Ping function
# ------------------------------------------------------------------

function DISCOVERING_HOSTS_WITH_TCPSYNCHRONIZATION(){
    nmap -v -n -sn -PS21,22,23,25,53,80,110,111,135,139,143,443,445,993,995,1723,3306,3389,5900,8080 \
        $(cat "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$DOWN_HOSTS_FILE" | xargs) \
        -oG "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$TEMP_DIR"/LIVE-HOSTS-TRY-2 \
        2>> "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LOG_FILE" | tee /dev/stdout \
        | grep -v Down | cut -f 2 -d " " >> "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LIVE_HOSTS_FILE" 2>> "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LOG_FILE"
}

# ------------------------------------------------------------------
# NMAP TCP ACK Ping function
# ------------------------------------------------------------------

function DISCOVERING_HOSTS_WITH_TCPACKNOWLEDGEMENT(){

      nmap -v -n -sn -PA21,22,23,25,53,80,110,111,135,139,143,443,445,993,995,1723,3306,3389,5900,8080 -iL "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$DOWN_HOSTS_FILE" -oA "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$TEMP_DIR"/LIVE-HOSTS-TRY-3 2>> "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LOG_FILE" &> /dev/null

      cat "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$TEMP_DIR"/LIVE-HOSTS-TRY-3.gnmap | grep Up | cut -f 2 -d " " >> "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LIVE_HOSTS_FILE" 2>> "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LOG_FILE"

      cat "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$TEMP_DIR"/LIVE-HOSTS-TRY-3.gnmap | grep Down | cut -f 2 -d " " > "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$DOWN_HOSTS_FILE" 2>> "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LOG_FILE" 
}

# ------------------------------------------------------------------
# NMAP UDP Ping function
# ------------------------------------------------------------------

function DISCOVERING_HOSTS_WITH_UDP(){

      nmap -v -n -sn -PU631,161,137,123,138,1434,445,135,67,53 -iL "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$DOWN_HOSTS_FILE" -oA "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$TEMP_DIR"/LIVE-HOSTS-TRY-4 2>> "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LOG_FILE" &> /dev/null

      cat "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$TEMP_DIR"/LIVE-HOSTS-TRY-4.gnmap | grep Up | cut -f 2 -d " " >> "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LIVE_HOSTS_FILE" 2>> "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LOG_FILE"

      cat "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$TEMP_DIR"/LIVE-HOSTS-TRY-4.gnmap | grep Down | cut -f 2 -d " " > "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$DOWN_HOSTS_FILE" 2>> "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LOG_FILE"
}

# ------------------------------------------------------------------
# Nmap Open Ports Scanning function
# ------------------------------------------------------------------

function OPENPORTS_NMAP(){

    nmap -v -Pn -p- $1 -oA "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$1" 2>> "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LOG_FILE" &> /dev/null

    cat "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$1".gnmap >> "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/ALL-HOSTS-OPEN-PORTS.gnmap

}


# ------------------------------------------------------------------
# Nmap Service Version Detection function
# ------------------------------------------------------------------

function VERSION_DETECTION(){

    nmap -v -Pn -sT -sV -A -O -sC $1 -p $2 -oA "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$1"-Version-Detection 2>> "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LOG_FILE" &> /dev/null

}


if [[ "${NOTIFY_CONF}" = true ]]; then

    echo -e "$(INFO_PRINT) Start Discovering Live Hosts using Nmap [ -n -sn ] Please wait..." | notify -silent

    echo -e "$(NOTIFY_PRINT) Notification Send"

  else

    echo -e "$(INFO_PRINT) Start Discovering Live Hosts using Nmap [ -n -sn ] Please wait..."

fi

# ------------------------------------------------------------------
# Run NMAP function
# ------------------------------------------------------------------

DISCOVERING_HOSTS_WITH_PING

# ------------------------------------------------------------------
# Run NMAP TCP SYN function
# ------------------------------------------------------------------

if [ -s "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$DOWN_HOSTS_FILE" ]; then

  echo -e "$(INFO_PRINT) Run TCP SYN ping [ -sn -PS21,22,23,25,53,80,110,111,135,139,143,443,445,993,995,1723,3306,3389,5900,8080 ] Please wait..."
  
  DISCOVERING_HOSTS_WITH_TCPSYNCHRONIZATION

fi

# ------------------------------------------------------------------
# Run nmap TCP ACK function
# ------------------------------------------------------------------

if [ -s "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$DOWN_HOSTS_FILE" ]; then

  echo -e "$(INFO_PRINT) Run TCP ACK ping [ -sn -PA21,22,23,25,53,80,110,111,135,139,143,443,445,993,995,1723,3306,3389,5900,8080 ] Please wait..."
  
  DISCOVERING_HOSTS_WITH_TCPACKNOWLEDGEMENT

fi

# ------------------------------------------------------------------
# Run nmap UDP function
# ------------------------------------------------------------------

if [ -s "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$DOWN_HOSTS_FILE" ]; then

  echo -e "$(INFO_PRINT) Run UDP ping  [ -sn -PU631,161,137,123,138,1434,445,135,67,53 ] Please wait..."
  
  DISCOVERING_HOSTS_WITH_UDP

fi


if [[ "${NOTIFY_CONF}" = true ]]; then

    echo -e "$(INFO_PRINT) Discovering Live Hosts is Completed" | notify -silent

    echo -e "$(NOTIFY_PRINT) Notification Send"

  else

    echo -e "$(INFO_PRINT) Discovering Live Hosts is Completed"

fi

duration=$SECONDS
echo -e "$(INFO_PRINT) Elapsed Time: $(($duration / 60)) minutes and $(($duration % 60)) seconds."

readarray -t ALL_LIVE_HOSTS < "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LIVE_HOSTS_FILE"

readarray -t ALL_DOWN_HOSTS < "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$DOWN_HOSTS_FILE"

if [[ "${NOTIFY_CONF}" = true ]]; then

    echo -e "$(INFO_PRINT) Number of Live Hosts found : ${yellow} ${#ALL_LIVE_HOSTS[@]} ${reset} (${green} "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LIVE_HOSTS_FILE" ${reset} )" | notify -silent
    echo -e "$(INFO_PRINT) Number of Downed Hosts found : ${red} ${#ALL_DOWN_HOSTS[@]} ${reset} (${red} "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$DOWN_HOSTS_FILE" ${reset} )" | notify -silent
    echo -e "$(NOTIFY_PRINT) Notification Send"

  else

    echo -e "$(INFO_PRINT) Number of Live Hosts found : ${yellow} ${#ALL_LIVE_HOSTS[@]} ${reset} (${green} "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$LIVE_HOSTS_FILE" ${reset} )"
    echo -e "$(INFO_PRINT) Number of Downed Hosts found : ${red} ${#ALL_DOWN_HOSTS[@]} ${reset} (${red} "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$DOWN_HOSTS_FILE" ${reset} )"

fi


# ------------------------------------------------------------------
# Open Ports Scanning
# ------------------------------------------------------------------

if [[ -z "${PORTSCAN}" ]]; then
  
    exit 0

fi

if [[ ${#ALL_LIVE_HOSTS[@]} -eq 0 ]]; then
  
    echo -e "$(ERROR_PRINT) No any Live Host found !!"
    exit 8

fi

if [[ "${NOTIFY_CONF}" = true ]]; then

    echo -e "$(INFO_PRINT) Start Scanning Open Ports using Nmap [ -v -Pn -p- ] Please wait..." | notify -silent

    echo -e "$(NOTIFY_PRINT) Notification Send"

  else

    echo -e "$(INFO_PRINT) Start Scanning Open Ports using Nmap [ -v -Pn -p- ] Please wait..."

fi

i=0

for HOST_KEY in ${!ALL_LIVE_HOSTS[@]}; do
  i=$((i + 1))
  echo -e "$(INFO_PRINT) Scanning Open Ports with Nmap on ${yellow}${ALL_LIVE_HOSTS[$HOST_KEY]}${reset} (${blue}${i}${reset}/${green}${#ALL_LIVE_HOSTS[@]}${reset})"
  OPENPORTS_NMAP ${ALL_LIVE_HOSTS[$HOST_KEY]}
done

if [[ "${NOTIFY_CONF}" = true ]]; then

    echo -e "$(INFO_PRINT) Scanning Open Ports is Completed" | notify -silent

    echo -e "$(NOTIFY_PRINT) Notification Send"

  else

    echo -e "$(INFO_PRINT) Scanning Open Ports is Completed"

fi


if [ -s "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/ALL-HOSTS-OPEN-PORTS.gnmap ]; then

  grep 'open' "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/ALL-HOSTS-OPEN-PORTS.gnmap | while read -r line
  do
      ip=$(echo $line | grep -oP '(?<=^Host: )(\d{1,3}\.){3}\d{1,3}')
      ports=$(echo "$line" | cut -d' ' -f4- | sed -e 's/, /\n/g' | cut -d/ -f 1 |  tr "\n" "," | sed -e 's/,$//g')
      echo $ip:$ports >> "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/ALL-HOSTS-OPEN-PORTS.txt
  done

  grep 'open' "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/ALL-HOSTS-OPEN-PORTS.gnmap | while read -r line
  do
      ip=$(echo $line | grep -oP '(?<=^Host: )(\d{1,3}\.){3}\d{1,3}')
      echo "$line" | cut -d' ' -f4- | sed -e 's/, /\n/g' | cut -d/ -f 1 | sed -e "s/^/$ip:/g" >> "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/ALL-HOSTS-OPEN-PORTS-STD.txt
  done

fi

duration=$SECONDS
echo -e "$(INFO_PRINT) Elapsed Time: $(($duration / 60)) minutes and $(($duration % 60)) seconds."
echo -e "$(INFO_PRINT) All Hosts with Open Ports are saved in : ${green} "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/ALL-HOSTS-OPEN-PORTS.txt ${reset}"
echo -e "$(INFO_PRINT) All Hosts with Open Ports are saved in (Standard output ): ${green} "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/ALL-HOSTS-OPEN-PORTS-STD.txt ${reset}"


# ------------------------------------------------------------------
# Service Version Detection
# ------------------------------------------------------------------

if [[ -z "${VERSIONDETECTION}" ]]; then
  
    echo -e "$(ERROR_PRINT) -p is required for Service Version Detection "
    exit 9

fi

if [[ "$EUID" -ne 0  ]]; then
  
  echo -e "$(ERROR_PRINT) Requires root privileges for Service Version Detection "
  exit 10

fi

if [[ "${NOTIFY_CONF}" = true ]]; then

    echo -e "$(INFO_PRINT) Start Service Version Detection using Nmap [ -v -Pn -sT -sV -A -O -sC ] Please wait..." | notify -silent

    echo -e "$(NOTIFY_PRINT) Notification Send"

  else

    echo -e "$(INFO_PRINT) Start Service Version Detection using Nmap [ -v -Pn -sT -sV -A -O -sC ] Please wait..."

fi


if [ -s "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/ALL-HOSTS-OPEN-PORTS.txt ]; then

  readarray -t ALL_HOSTS_OPEN_PORTS < "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/ALL-HOSTS-OPEN-PORTS.txt

  i=0

  for HOST_WITH_PORTS_KEY in ${!ALL_HOSTS_OPEN_PORTS[@]}; do
    i=$((i + 1))
    echo -e "$(INFO_PRINT) Scanning Service Version Detection with Nmap on ${yellow}${ALL_HOSTS_OPEN_PORTS[$HOST_WITH_PORTS_KEY]}${reset} (${blue}${i}${reset}/${green}${#ALL_HOSTS_OPEN_PORTS[@]}${reset})"
    ip=$(echo ${ALL_HOSTS_OPEN_PORTS[$HOST_WITH_PORTS_KEY]} | cut -d: -f 1)
    ports=$(echo ${ALL_HOSTS_OPEN_PORTS[$HOST_WITH_PORTS_KEY]} | cut -d: -f 2)
    VERSION_DETECTION "$ip" "$ports"
  done

fi

if [[ "${NOTIFY_CONF}" = true ]]; then

    echo -e "$(INFO_PRINT) Service Version Detection is Completed" | notify -silent

    echo -e "$(NOTIFY_PRINT) Notification Send"

  else

    echo -e "$(INFO_PRINT) Service Version Detection is Completed"

fi

# ------------------------------------------------------------------
# Moveing unused files (*.nmap, *.gnmap and *.xml) into .tmp
# ------------------------------------------------------------------

find "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR" -maxdepth 1 -type f ! \( -name "*txt" -o -name "*Version-Detection.nmap"  \) | while read -r FILES
do

  mv $FILES  "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$TEMP_DIR"/

done

# ------------------------------------------------------------------
# All Task Done
# ------------------------------------------------------------------

duration=$SECONDS
echo -e "$(INFO_PRINT) Elapsed Time: $(($duration / 60)) minutes and $(($duration % 60)) seconds."
echo -e "$(INFO_PRINT) All Results are saved in : ${green} "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR" ${reset}"
echo -e "$(INFO_PRINT) All gnmap and xml file are saved in : ${green} "$MAIN_OUTPUT_DIR"/"$NMAP_OUTPUT_DIR"/"$TEMP_DIR"/ ${reset}"

if [[ "${NOTIFY_CONF}" = true ]]; then

    echo -e "$(INFO_PRINT) All Task Done" | notify -silent

    echo -e "$(NOTIFY_PRINT) Notification Send"

  else

    echo -e "$(INFO_PRINT) All Task Done"

fi
