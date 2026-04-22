#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SYMLINK_MAP_FILE="$SCRIPT_DIR/symlink_map.conf"

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
force_symlink () {
    local source="$1"
    local target="$2"

    if [ -d "$target" ] && [ ! -L "$target" ]; then
        echo "Cannot replace directory with symlink: $target"
        return 1
    fi

    if [ -e "$target" ] || [ -L "$target" ]; then
        rm -f "$target"
    fi

    ln -sfnv "$source" "$target"
}

resolve_symlink_destination () {
    local destination="$1"

    case "$destination" in
        home)
            echo "$HOME"
            ;;
        home/*)
            echo "$HOME/${destination#home/}"
            ;;
        "~")
            echo "$HOME"
            ;;
        "~/"*)
            echo "$HOME/${destination#\~/}"
            ;;
        /*)
            echo "$destination"
            ;;
        *)
            echo "$SCRIPT_DIR/$destination"
            ;;
    esac
}

resolve_symlink_source_glob () {
    local source_glob="$1"

    case "$source_glob" in
        /*)
            echo "$source_glob"
            ;;
        *)
            echo "$SCRIPT_DIR/$source_glob"
            ;;
    esac
}

link_symlink_map () {
    local destination source_glob target_name destination_dir source_pattern

    if [ ! -f "$SYMLINK_MAP_FILE" ]; then
        echo "Missing symlink map: $SYMLINK_MAP_FILE"
        return 1
    fi

    while IFS='|' read -r destination source_glob target_name || [ -n "$destination$source_glob$target_name" ]; do
        [[ -z "${destination//[[:space:]]/}" ]] && continue
        [[ "$destination" == \#* ]] && continue

        if [ -z "$source_glob" ]; then
            echo "Invalid symlink map row: $destination"
            return 1
        fi

        destination_dir=$(resolve_symlink_destination "$destination")
        source_pattern=$(resolve_symlink_source_glob "$source_glob")
        mkdir -p "$destination_dir"

        local matches=()
        local nullglob_state dotglob_state
        nullglob_state=$(shopt -p nullglob)
        dotglob_state=$(shopt -p dotglob)
        shopt -s nullglob dotglob
        matches=( $source_pattern )
        eval "$nullglob_state"
        eval "$dotglob_state"

        if [ "${#matches[@]}" -eq 0 ]; then
            echo "No files matched symlink source: $source_glob"
            continue
        fi

        if [ -n "$target_name" ] && [ "${#matches[@]}" -ne 1 ]; then
            echo "Target name requires exactly one source match: $source_glob"
            return 1
        fi

        local filepath name
        for filepath in "${matches[@]}"; do
            if [ -n "$target_name" ]; then
                name="$target_name"
            else
                name=$(basename "$filepath")
            fi
            force_symlink "$filepath" "$destination_dir/$name" || return 1
        done
    done < "$SYMLINK_MAP_FILE"
}

remove_stale_agent_link () {
    local target="$1"
    local source

    if [ ! -L "$target" ]; then
        return 0
    fi

    source=$(readlink "$target")
    case "$source" in
        "$SCRIPT_DIR/symlinked_to_home/AGENTS.md"|"AGENTS.md"|"../AGENTS.md"|"../../AGENTS.md")
            rm -fv "$target"
            ;;
    esac
}

remove_stale_literal_glob_link () {
    local target="$HOME/*"
    local source

    if [ ! -L "$target" ]; then
        return 0
    fi

    source=$(readlink "$target")
    if [ "$source" = "$SCRIPT_DIR/symlinked_to_home/*" ]; then
        rm -fv "$target"
    fi
}

cleanup_stale_symlinks () {
    remove_stale_literal_glob_link
    remove_stale_agent_link "$HOME/AGENTS.md"
    remove_stale_agent_link "$HOME/CLAUDE.md"
    remove_stale_agent_link "$HOME/.config/claude/CLAUDE.md"
}

link () {
    echo "${Cyan}Symlinking dotfiles...$Reset"
    echo "This will symlink the files in this repo to the home directory"
    if user_ack ; then
        link_symlink_map || return 1
        cleanup_stale_symlinks

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
