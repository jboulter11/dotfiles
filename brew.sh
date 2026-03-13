#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Install homebrew if it is not installed
which brew 1>&/dev/null
if [ ! "$?" -eq 0 ] ; then
	echo "Homebrew not installed. Attempting to install Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
	if [ ! "$?" -eq 0 ] ; then
		echo "Something went wrong. Exiting..." && exit 1
	fi
fi

# Make sure we're using the latest Homebrew
brew update

# Install all formulae and casks from Brewfile
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
brew bundle --file="$SCRIPT_DIR/Brewfile"

# xcode commandline tools
sudo xcode-select --install

# install fzf completions
"$(brew --prefix)"/opt/fzf/install

# Xcodes Themes
mkdir -p ~/Library/Developer/Xcode/UserData/FontAndColorThemes/
cp "$SCRIPT_DIR"/xcode_themes/*.xccolortheme ~/Library/Developer/Xcode/UserData/FontAndColorThemes/
