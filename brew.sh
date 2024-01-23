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

git -C $(brew --repo homebrew/core) checkout master

# Make sure we’re using the latest Homebrew
brew update

# Install
brew install zsh
brew install tmux
brew install fzf
brew install swift-sh
brew install ripgrep
brew install pyenv
brew install --cask alfred
brew install fd
brew install sourcery
brew install rbenv
brew install shellcheck
brew install socat
brew install --cask setapp
brew install --cask sim-genie
brew install --cask 1password
brew install --cask 1password/tap/1password-cli
brew install --cask iterm2
brew install --cask visual-studio-code
brew install --cask deckset
brew install --cask roon
brew install --cask loopback
brew install --cask reveal
brew install --cask nslogger
brew install --cask paw
brew install --cask bettertouchtool
brew install --cask meetingbar
brew install --cask db-browser-for-sqlite
brew install --cask karabiner-elements
brew install --cask xcodes
brew install neovim
brew install --cask readdle-spark
brew install --cask fertigt-slate
brew install --cask obsidian
brew install devutils
brew install --cask copilot-for-xcode
brew install gh
brew install --cask keyboard-maestro
brew install --cask arc
brew install --cask charles

# xcode commandline tools
sudo xcode-select --install

# install fzf completions
"$(brew --prefix)"/opt/fzf/install

# Xcodes Themes
cp xcode_themes/*.xccolortheme ~/Library/Developer/Xcode/UserData/FontAndColorThemes/ 
