#!/bin/sh
#
# Nmap Schedular
#
# Variables
WORKSPACE_DIR=""
NMAP_FLAGS=""
TARGET=""
PROJECT=""
OUT_FLAG=""
TIME=""
FILENAME=""
echo -ne "\e[38;5;208m"
echo "***************************************"
echo "*           Nmap Schedular            *"
echo "***************************************"
echo -ne "\e[0m"
#
# Check for dependencies
# Check for nmap(1)
if ! [ -x "$(command -v nmap)" ]; then
    echo -e "\e[1;31mERROR: nmap(1) installation not found!\e[0m" 1>&2
    echo -e "\e[1;31mPlease install nmap(1) " 1>&2
    echo -e "\e[1;32m# apt update && apt install nmap " 1>&2
    echo -e "\e[1;33mExiting...\e[0m" 1>&2
    exit 1
fi
# Check for at(1)
if ! [ -x "$(command -v at)" ]; then
    echo -e "\e[1;31mERROR: at(1) installation not found!\e[0m" 1>&2
    echo -e "\e[1;31mPlease install at(1) " 1>&2
    echo -e "\e[1;32m# apt update && apt install at " 1>&2
    echo -e "\e[1;33mExiting...\e[0m" 1>&2
    exit 1
fi

# Check for root permissions
if (( EUID != 0 )); then
    echo -e "\e[1;31mERROR: This script requires sudo (root)!\e[0m" 1>&2
    echo -e "\e[1;33mExiting...\e[0m" 1>&2
    exit 1
fi

#Create the Project directory
#Ask for project name
echo -n "Enter the project name: "
read PROJECT

if [[ -z "$PROJECT" ]]; then
   echo -e "\e[1;31mERROR: Project name can not be empty!\e[0m" 1>&2
   echo -e "\e[1;33mExiting...\e[0m" 1>&2
   exit 1
fi

#Create directory at
while :
do
    echo -ne "\e[94m"
    echo "***************************************"
    echo "*      Select Project Workspace       *"
    echo "***************************************"
    echo "* [1] Current Working Directory ($(pwd)) "
    echo "* [2] Home Directory ($HOME) "
    echo "* [3] Somewhere else (Specify path)   *"
    echo "*                                     *"
    echo "* [q]  Quit/Exit                      *"
    echo "***************************************"
    echo -ne "\e[0m"
    echo -n "Enter your menu choice [1-3, or q]: "
    read line
    case $line in 
        1) WORKSPACE_DIR=$(pwd);;
        2) WORKSPACE_DIR=$HOME;;
        3) echo -n "Enter the absolute path to your directroy: "
        read WORKSPACE_DIR;;
        q) exit 0;;
        *) continue;;
    esac
    break
done
#make project dir

echo -e "\e[90mCreating project directory at $WORKSPACE_DIR\e[0m"
sleep 1
#change dir
if ! cd $WORKSPACE_DIR 2>/dev/null; then
    echo -e "\e[1;31mERROR: The workspace directory $WORKSPACE_DIR does not exist!\e[0m" 1>&2
    echo -e "\e[1;33mExiting...\e[0m" 1>&2
    exit 1
fi
#make dir
if [ ! -d "$PROJECT" ]; then
   mkdir $PROJECT
   echo "\e[90m$PROJECT has been created in your working path\e[0m"
else
   echo -e "\e[1;33mWarning: Directory already exists!\e[0m"
   echo -e "\e[90mSelecting preexisting directory...\e[0m"
fi

#Get the file name(Common ports,all_tcp,etc)
echo -n "Enter the filename to save output (saved in project folder): "
read FILENAME

if [[ -z "$FILENAME" ]]; then
   echo -e "\e[1;31mERROR: File name can not be empty!\e[0m" 1>&2
   echo -e "\e[1;33mExiting...\e[0m" 1>&2
   exit 1
fi

#Create directory at
while :
do
    echo -ne "\e[94m"
    echo "***************************************"
    echo "*         Select Output Format        *"
    echo "***************************************"
    echo "* [1] -oN (Default)                   *"
    echo "* [2] -oG (Grep)                      *"
    echo "* [3] -oX (XML)                       *"
    echo "* [4] -oA (All Formats)               *"
    echo "*                                     *"
    echo "* [q]  Quit/Exit                      *"
    echo "***************************************"
    echo -ne "\e[0m"
    echo -n "Enter your menu choice [1-4, or q]: "
    read line
    case $line in 
        1) OUT_FLAG="-oN";;
        2) OUT_FLAG="-oG";;
        3) OUT_FLAG="-oX";;
        4) OUT_FLAG="-oA";;
        q) exit 0;;
        *) continue;;
    esac
    break
done

#Ask for the target(file or host)
echo -n "Would you like to load the target from a file (nmap's -iL flag)? [Y/n]: "
read line
if [[ "$line" == "Y" ]]; then
    #ask for file name
    echo -n "Enter the path the target file: "
    read line
    TARGET="-iL $line"
else
    echo -n "Enter the IP Address, Range or Hostname to scan (use nmap syntax): "
    read TARGET
fi
#Error checking
#TODO

# Prompt time
echo "Scheduling is done via the 'at' command. Syntax examples can be found below:"
echo ""
echo "Schedule Immediately: now"
echo "Delay Scan by 10 minutes: now + 10 minutes"
echo "Delay Scan 24 hours: now + 24 hours"
echo "Schedule for time in am: 4am"
echo "Schedule for time in pm: 4pm"
echo ""
echo "Additional Options:"
echo "For example, to run a job at 4pm three days from now, you would do"
echo "4pm + 3 days"
echo "to run a job at 10:00am on July 31, you would do"
echo "10am Jul 31"
echo "and to run a job at 1am tomorrow, you would do"
echo "1am tomorrow"
echo ""
echo -n "When do you want to schedule the scan for? (USE PROPER SYNTAX): "
read TIME
if [[ -z "$TIME" ]]; then
   echo -e "\e[1;31mERROR: Time can not be empty!\e[0m" 1>&2
   echo -e "\e[1;33mExiting...\e[0m" 1>&2
   exit 1
fi

#nmap flags
while :
do
    echo -ne "\e[94m"
    echo "***************************************"
    echo "*           Select Nmap Scan          *"
    echo "***************************************"
    echo "* [1]  Ping Sweep                     *"
    echo "* [2]  Common Ports                   *"
    echo "* [3]  Top 2000 Ports - TCP & UDP     *"
    echo "* [4]  TCP Scan - Top 1000            *"
    echo "* [5]  UDP Scan - Top 1000            *"
    echo "* [6]  All Ports - TCP Only           *"
    echo "* [7]  All Ports (TCP & UDP) - SLOW   *"
    echo "*                                     *"
    echo "* [8]     **CUSTOM SCAN**             *"
    echo "*                                     *"
    echo "* [q]  Quit/Exit                      *"
    echo "***************************************"
    echo -ne "\e[0m"
    echo -n "Enter your menu choice [1-8,or q]: "
    read line
    case $line in 
        1) NMAP_FLAGS="-sn";;
        2) NMAP_FLAGS="-sS -p80,443,22,23,3389,8080,10443,8000,21,990";;
        3) NMAP_FLAGS="-sS -sU";;
        4) NMAP_FLAGS="-sS";;
        5) NMAP_FLAGS="-sU";;
        6) NMAP_FLAGS="-sS -p-";;
        7) NMAP_FLAGS="-sS -sU -p-";;
        8) echo -n "Enter your custom nmap flags: "
        read NMAP_FLAGS;;
        q) exit 0;;
        *) continue;;
    esac
    break
done

#skip ping probes
echo -n "Would you like to skip ping probes (Slower, but more accurate scan) [Y/n]: "
read line
if [[ "$line" == "Y" ]]; then
    echo -e "\e[90mAdding -Pn flag\e[0m"
    NMAP_FLAGS="-Pn $NMAP_FLAGS"
fi

#begin scans
echo nmap $NMAP_FLAGS $TARGET $OUT_FLAG $PROJECT/$FILENAME | at $TIME