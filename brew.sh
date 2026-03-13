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

# Formulae
brew install aria2
brew install awscli
brew install bazelisk
brew install cocoapods
brew install coreutils
brew install direnv
brew install fd
brew install fzf
brew install gh
brew install git-delta
brew install git-town
brew install go
brew install graphviz
brew install imagemagick
brew install jq
brew install just
brew install lazygit
brew install lcov
brew install luarocks
brew install neovide
brew install neovim
brew install node
brew install pyenv
brew install rbenv
brew install ripgrep
brew install rsync
brew install shellcheck
brew install socat
brew install sourcery
brew install swift-sh
brew install swiftformat
brew install tmux
brew install tree-sitter-cli
brew install uv
brew install withered-magic/brew/starpls
brew install xcodesorg/made/xcodes
brew install zsh

# Casks
brew install --cask 1password
brew install --cask 1password-cli
brew install --cask alfred
brew install --cask arc
brew install --cask beekeeper-studio
brew install --cask bettertouchtool
brew install --cask cmux
brew install --cask copilot-for-xcode
brew install --cask cursor
brew install --cask deckset
brew install --cask devutils
brew install --cask fertigt-slate
brew install --cask ghostty
brew install --cask hiddenbar
brew install --cask hopper-disassembler
brew install --cask iterm2
brew install --cask kaleidoscope
brew install --cask karabiner-elements
brew install --cask keyboard-maestro
brew install --cask loom
brew install --cask loopback
brew install --cask meetingbar
brew install --cask nslogger
brew install --cask obsidian
brew install --cask proxyman
brew install --cask readdle-spark
brew install --cask reveal
brew install --cask roon
brew install --cask sim-genie
brew install --cask slack
brew install --cask visual-studio-code
brew install --cask vlc
brew install --cask xcodes-app

# xcode commandline tools
sudo xcode-select --install

# install fzf completions
"$(brew --prefix)"/opt/fzf/install

# Xcodes Themes
cp xcode_themes/*.xccolortheme ~/Library/Developer/Xcode/UserData/FontAndColorThemes/
