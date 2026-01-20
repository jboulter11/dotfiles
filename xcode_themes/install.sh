#!/bin/sh
THEME_DIR=~/Library/Developer/Xcode/UserData/FontAndColorThemes/
SCRIPT_PATH="$(readlink -f "$0")"
BASE_DIR="$(dirname "$SCRIPT_PATH")"

if [ -d ~/Library/Developer/Xcode ]
then 
    echo "> Xcode detected. ✅"
    echo "> Copying theme ..."
    mkdir -p $THEME_DIR
    echo "$BASE_DIR"
    cp "$BASE_DIR/*.xccolortheme" ~/Library/Developer/Xcode/UserData/FontAndColorThemes/
    echo "> Done!"
    echo "> You can restart Xcode now."
else
    echo "Xcode doesn't seem to be installed on your computer. 🚨"
fi
