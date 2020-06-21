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
#


# Check for root permissions
if (( EUID != 0 )); then
   echo -e "\e[1;31mERROR: This script requires sudo (root)!\e[0m" 1>&2
   echo -e "\e[1;33mExiting...\e[0m" 1>&2
   exit 1
fi

#Create the Project directory
#Ask for project name
echo -n "Enter the project name:"
read line
PROJECT=$line

#Create directory at
while :
do
    echo "where do you wanna create the dir at?"
    echo "[1] Current Working Directory ($(pwd))"
    echo "[2] Home Directory ($HOME)"
    echo "[3] Somewhere else (Specify path)"
    echo -n "Enter your menu choice [1-3, or q]: "
    read line
    case $line in 
        1) WORKSPACE_DIR=$(pwd);;
        2) WORKSPACE_DIR=$HOME;;
        3) echo "Enter the absolute path to your directroy."
        read line
        WORKSPACE_DIR=$line;;
        q) exit 0;;
        *) continue;;
    esac
    break
done
#make project dir

echo "Creating project directory at $WORKSPACE_DIR"
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
   echo  $PROJECT "has been created in your working path"
else
   echo -e "\e[1;33mDIRECTORY ALREADY EXISTS!\e[0m"
fi

#Get the file name(Common ports,all_tcp,etc)
echo -n "Enter the filename to save output (saved in project folder): "
read filename

#Create directory at
while :
do
    echo "Output type?"
    echo "[1] -oN (Default)"
    echo "[2] -oG (Grep)"
    echo "[3] -oX (XML)"
    echo "[4] -oA (All Formats)"
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
#Ask for the target

echo 
if 
echo -n "Enter the IP Address, Range or Hostname to scan (use nmap syntax): "
read target


#from stdin or from file(-iL)