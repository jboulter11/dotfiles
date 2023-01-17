#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Install homebrew if it is not installed
which brew 1>&/dev/null
if [ ! "$?" -eq 0 ] ; then
	echo "Homebrew not installed. Attempting to install Homebrew"
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	if [ ! "$?" -eq 0 ] ; then
		echo "Something went wrong. Exiting..." && exit 1
	fi
fi

pushd /Applications && curl http://www.ninjamonkeysoftware.com/slate/versions/slate-latest.tar.gz | tar -xz ; popd

# Make sure we’re using the latest Homebrew
brew update

# Install
brew install zsh
brew install tmux
brew install fzf
brew install swift-sh
brew install ripgrep
brew install pyenv
brew install robotsandpencils/made/xcodes
brew install --cask alfred
brew install fd
brew install sourcery
brew install rbenv
brew install shellcheck
brew install socat

# xcode commanline tools
sudo xcode-select --install

# install fzf completions
$(brew --prefix)/opt/fzf/install

