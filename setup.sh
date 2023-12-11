#!/bin/sh

SCRIPT_PATH="$(readlink -f "$0")"
BASE_DIR="$(dirname "$SCRIPT_PATH")"

source "$BASE_DIR/utilities.sh"

# Setup FS
setup_file_system () {
    pushd ~ || exit 1
    # Create code directory
    mkdir ~/src

    mkdir ~/screenshots
    defaults write com.apple.screencapture location ~/screenshots
    popd || exit 1
}

# TODO : Delete symlinks to deleted files
# TODO - add support for -f and --force
link () {
    echo "This utility will symlink the files in this repo to the home directory"
    if user_ack ; then
        for file in $( ls -A symlinked_to_home/ ) ; do
            ln -sv "$BASE_DIR/symlinked_to_home/$file" "$HOME"
        done

            mkdir -p "$BASE_DIR/.config"
            for file in $( ls -A symlinked_to_config/ ) ; do
                    ln -sv "$BASE_DIR/symlinked_to_config/$file" "$HOME/.config"
            done

            echo "Symlinking complete"
    else
        echo "Symlinking cancelled by user"
        return 1
    fi
}

editor_themes() {
    # Copy Vim color scheme
    # Symlinking doesn't seem to work for this
    mkdir "$HOME/.vim"
    mkdir "$HOME/.vim/colors"
    cp  "monokai.vim" "$HOME/.vim/colors/monokai.vim"
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    vim +PluginInstall +qall
    
    # xcode themes
    THEME_DIR="$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes/"

    if [ -d ~/Library/Developer/Xcode ]
    then
        echo "> Xcode detected. ✅"
        echo "> Copying themes ..."
        mkdir -p $THEME_DIR
        cp "$BASE_DIR/xcode_themes/*.xccolortheme" "$THEME_DIR"
        echo "> Done!"
        echo "> You can restart Xcode now."
    else
        echo "Xcode doesn't seem to be installed on your computer. 🚨"
    fi
}

install_tools () {
    if [ "$( echo "$OSTYPE" | grep 'darwin' )" ] ; then
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
    echo "This utility will install zprezto, set zsh as default and set jim prompt"
    if user_ack ; then
        echo "Installing zprezto and setting prompt."
        zsh zprezto.sh
        
        echo "Setting zsh as default shell."
        chsh -s /bin/zsh
    else
        echo "zprezto installation cancelled by user"
    fi
}

colemak () {
    echo "This utility will install colemak mod-dh keyboard layout"
    if user_ack ; then
        echo "Installing colemak."
        pushd ~/src/ || exit 1
        git clone https://github.com/ColemakMods/mod-dh.git
        popd || exit 1

        pushd ~/src/mod-dh/macOS || exit 1
        sudo cp -r Colemak\ DH.bundle /Library/Keyboard\ Layouts/Colemak\ DH.bundle
        popd || exit 1

        echo "Please logout and login, if needed go to SysPref > Keyboard > Input Sources and enable the keyboard"
        
    else
        echo "colemake install cancelled by user"
    fi
}

all () {
    install_zprezto
    setup_file_system
    link
    editor_themes
    install_tools
    colemak
}

menu () {
    echo "
    $BBlue 1) $Reset Install zprezto
    $BBlue 2) $Reset Setup file system
    $BBlue 3) $Reset Symlink dotfiles
    $BBlue 4) $Reset Install editor themes
    $BBlue 5) $Reset Install brew packages
    $BBlue 6) $Reset Install Colemak Mod-dh
    $BGreen 7) $Reset All
    $BRed 0) $Reset Exit"
    read a
    case $a in
        1) install_zprezto ; menu ;;
        2) setup_file_system ; menu ;;
        3) link ; menu ;;
        4) editor_themes ; menu ;;
        5) install_tools ; menu ;;
        6) colemak ; menu ;;
        7) all ; menu ;;
        0) exit ;;
        *) echo "$BRed Bad selection$Reset" ;
    esac
}

menu
