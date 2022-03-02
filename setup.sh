#!/bin/sh
source "${BASH_SOURCE%/*}/utilities.sh"

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
		for file in $( ls -A symlinked_to_home/ ) ; do
			ln -sv "$PWD/symlinked_to_home/$file" "$HOME"
		done

  		# TODO: source files here?
		echo "Symlinking complete"
	else
		echo "Symlinking cancelled by user"
		return 1
	fi
}

vim_theme() {
    # Copy Vim color scheme
    # Symlinking doesn't seem to work for this
    mkdir "$HOME/.vim"
    mkdir "$HOME/.vim/colors"
    cp  "../monokai.vim" "$HOME/.vim/colors/monokai.vim"

}

install_tools () {
	if [ $( echo "$OSTYPE" | grep 'darwin' ) ] ; then
		echo "This utility will install useful utilities using Homebrew"
		if user_ack ; then
			echo "Installing useful stuff using brew. This may take a while..."
			sh brew.sh
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
        zsh zprezto.sh
    else
        echo "zprezto installation cancelled by user"
    fi
}

all () {
    install_zprezto
    setup_file_system
    link
    vim_theme
    install_tools
}

menu () {
    echo "
    $BBlue 1) $Reset Install zprezto
    $BBlue 2) $Reset Setup file system
    $BBlue 3) $Reset Symlink dotfiles
    $BBlue 4) $Reset Install vim theme
    $BBlue 5) $Reset Install brew packages
    $BGreen 6) $Reset All
    $BRed 0) $Reset Exit"
    read a
    case $a in
        1) install_zprezto ; menu ;;
        2) setup_file_system ; menu ;;
        3) link ; menu ;;
        4) vim_theme ; menu ;;
        5) install_tools ; menu ;;
        6) all ; menu ;;
        0) exit ;;
        *) echo "$BRed Bad selection$Reset" ;
    esac
}

menu
