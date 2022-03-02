#!/bin/sh

user_ack () {
    echo "Proceed? (y/n)"
    read resp
    [[ "$resp" =~ y|Y ]] && return 0
    return 1
}

##
# Color variables
##
black='\e[30m'
red='\e[31m'
green='\e[32m'
yellow='\e[33m'
blue='\e[34m'
magenta='\e[35m'
cyan='\e[36m'
lightred='\e[91m'
lightgreen='\e[92m'
lightyellow='\e[93m'
lightblue='\e[94m'
lightmagenta='\e[95m'
lightcyan='\e[96m'
white='\e[97m'
clear='\e[0m'

bold='\e[1m'
faint='\e[2m'
italic='\e[3m'
underline='\e[4m'

color () {
    echo -ne $1$2$clear
}
