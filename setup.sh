#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$SCRIPT_DIR/utilities.sh"

# Setup FS
setup_file_system () {
    echo "${Cyan}Setting up file system...$Reset"
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
    echo "${Cyan}Symlinking dotfiles...$Reset"
    echo "This will symlink the files in this repo to the home directory"
    if user_ack ; then
        for filepath in "$SCRIPT_DIR"/symlinked_to_home/.* "$SCRIPT_DIR"/symlinked_to_home/*; do
            local name
            name=$(basename "$filepath")
            [[ "$name" == "." || "$name" == ".." ]] && continue
            ln -sfnv "$filepath" "$HOME/$name"
        done

        mkdir -p "$HOME/.config"
        for filepath in "$SCRIPT_DIR"/symlinked_to_config/*; do
            local name
            name=$(basename "$filepath")
            ln -sfnv "$filepath" "$HOME/.config/$name"
        done

        # Per-file config symlinks (for config dirs with runtime files we don't track)
        for dir in "$SCRIPT_DIR"/config_files/*; do
            local name
            name=$(basename "$dir")
            mkdir -p "$HOME/.config/$name"
            for filepath in "$dir"/*; do
                local fname
                fname=$(basename "$filepath")
                ln -sfnv "$filepath" "$HOME/.config/$name/$fname"
            done
        done

        # Claude Code config (per-file into ~/.claude/)
        mkdir -p "$HOME/.claude"
        for filepath in "$SCRIPT_DIR"/config_files/claude/*; do
            local fname
            fname=$(basename "$filepath")
            ln -sfnv "$filepath" "$HOME/.claude/$fname"
        done

        mkdir -p "$HOME/Library/Application Support/espanso/match/"
        for filepath in "$SCRIPT_DIR"/symlinked_to_espanso/*; do
            local name
            name=$(basename "$filepath")
            ln -sfnv "$filepath" "$HOME/Library/Application Support/espanso/match/$name"
        done

        echo "Symlinking complete"
    else
        echo "Symlinking cancelled by user"
        return 1
    fi
}

editor_themes() {
    echo "${Cyan}Installing editor themes...$Reset"
    THEME_DIR="$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes/"

    if [ -d ~/Library/Developer/Xcode ]
    then
        echo "> Xcode detected."
        echo "> Copying themes ..."
        mkdir -p "$THEME_DIR"
        cp "$SCRIPT_DIR"/xcode_themes/*.xccolortheme "$THEME_DIR"
        echo "> Done!"
        echo "> You can restart Xcode now."
    else
        echo "Xcode doesn't seem to be installed on your computer."
    fi
}

configure_git_email () {
    echo "${Cyan}Configuring git email...$Reset"
    echo "Select git email:"
    echo "  1) jboulter11@gmail.com"
    echo "  2) jboulter@dropbox.com"
    echo "  3) Enter a custom email"
    read selection
    case $selection in
        1) email="jboulter11@gmail.com" ;;
        2) email="jboulter@dropbox.com" ;;
        3) echo "Enter email:"; read email ;;
        *) echo "$BRed Bad selection$Reset"; return 1 ;;
    esac
    cat > "$HOME/.gitconfig-local" <<EOF
[user]
	email = $email
EOF
    echo "Git email set to $email in ~/.gitconfig-local"
}

install_tools () {
    echo "${Cyan}Installing brew packages...$Reset"
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
    echo "${Cyan}Installing zprezto...$Reset"
    echo "This will install zprezto, set zsh as default, and set jim prompt"
    if user_ack ; then
        echo "Installing zprezto and setting prompt."
        zsh zprezto.sh

        echo "Setting zsh as default shell."
        chsh -s /bin/zsh
    else
        echo "zprezto installation cancelled by user"
    fi
}

configure_claude () {
    echo "${Cyan}Configuring Claude Code...$Reset"
    echo "This will install Claude Code (if needed) and configure settings"
    if user_ack ; then
        # Install Claude Code
        if ! command -v claude &> /dev/null; then
            echo "Installing Claude Code..."
            curl -fsSL https://claude.ai/install.sh | bash
        else
            echo "Claude Code already installed: $(claude --version)"
        fi

        # Configure settings
        local settings_file="$HOME/.claude/settings.json"
        mkdir -p "$HOME/.claude"

        if [ ! -f "$settings_file" ]; then
            echo '{}' > "$settings_file"
        fi

        # Idempotently set statusLine config (preserves all other settings)
        local tmp
        tmp=$(jq '.statusLine = {"type": "command", "command": "~/.claude/statusline-command.sh"}' "$settings_file") && \
            echo "$tmp" > "$settings_file"

        echo "Claude Code settings updated: statusLine configured"
    else
        echo "Claude Code configuration cancelled by user"
    fi
}

colemak () {
    echo "${Cyan}Installing Colemak Mod-dh...$Reset"
    echo "This will install the colemak mod-dh keyboard layout"
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
        echo "colemak install cancelled by user"
    fi
}

all () {
    install_zprezto
    setup_file_system
    link
    install_tools
    configure_git_email
    configure_claude
    editor_themes
    colemak
}

menu () {
    echo "
    $BBlue 1) $Reset Install zprezto
    $BBlue 2) $Reset Setup file system
    $BBlue 3) $Reset Symlink dotfiles
    $BBlue 4) $Reset Install brew packages
    $BBlue 5) $Reset Configure git email
    $BBlue 6) $Reset Configure Claude Code
    $BBlue 7) $Reset Install editor themes
    $BBlue 8) $Reset Install Colemak Mod-dh
    $BGreen 9) $Reset All
    $BRed 0) $Reset Exit"
    read -sn1 a
    case $a in
        1) install_zprezto ; menu ;;
        2) setup_file_system ; menu ;;
        3) link ; menu ;;
        4) install_tools ; menu ;;
        5) configure_git_email ; menu ;;
        6) configure_claude ; menu ;;
        7) editor_themes ; menu ;;
        8) colemak ; menu ;;
        9) all ; menu ;;
        0) exit ;;
        *) echo "$BRed Bad selection$Reset" ;
    esac
}

menu
