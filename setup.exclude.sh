#!/bin/sh
source "${BASH_SOURCE%/*}/utilities.exclude.sh"

# Setup FS
setup_file_system () {
	pushd ~
    # Create code directory
	mkdir ~/code
    # clone notes repository to create notes directory
	git clone https://github.com/jboulter11/notes
	popd
}

# TODO : Delete symlinks to deleted files
# Is this where rsync shines?
# TODO - add support for -f and --force
link () {
	echo "This utility will symlink the files in this repo to the home directory"
	if user_ack ; then
		for file in $( ls -A | grep -vE '\.exclude*|\.git$|\.gitignore|.*.md' ) ; do
			ln -sv "$PWD/$file" "$HOME"
		done
		# TODO: source files here?
		echo "Symlinking complete"
	else
		echo "Symlinking cancelled by user"
		return 1
	fi
}

install_tools () {
	if [ $( echo "$OSTYPE" | grep 'darwin' ) ] ; then
		echo "This utility will install useful utilities using Homebrew"
		if user_ack ; then
			echo "Installing useful stuff using brew. This may take a while..."
			sh brew.exclude.sh
		else
			echo "Brew installation cancelled by user"
		fi
	else
		echo "Skipping installations using Homebrew because MacOS was not detected..."
	fi
}

install_zprezto () {
    echo "This utility will install zprezto, install and set jim prompt"
    if user_ack ; then
        echo "Installing zprezto and setting prompt."
        zsh zprezto.exclude.sh
    else
        echo "zprezto installation cancelled by user"
    fi
}

setup_file_system
link
install_tools

