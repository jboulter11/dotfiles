# Dotfiles

Personal macOS development environment setup.

## What's Included

- **Shell**: zsh with [zprezto](https://github.com/sorin-ionescu/prezto) and custom prompt
- **Editor**: Neovim (kickstart-based config with lazy.nvim)
- **Terminal**: Ghostty with Monokai theme
- **Packages**: Homebrew formulae and casks via `Brewfile`
- **macOS**: Screenshot location, Colemak Mod-DH keyboard layout
- **Themes**: Xcode color themes, Deckset presentation themes
- **Tools**: Espanso text expansion, Karabiner, Alfred workflows, Keyboard Maestro macros

## Setup

Run `./setup.sh` for an interactive menu:

1. Install zprezto (zsh framework + custom prompt)
2. Setup file system (`~/src`, `~/screenshots`)
3. Symlink dotfiles to `~` and `~/.config`
4. Install editor themes (Xcode)
5. Install Homebrew packages (from `Brewfile`)
6. Install Colemak Mod-DH keyboard layout

Or select **All** to run everything.

## File Structure

    symlinked_to_home/     -> symlinked to ~/
    symlinked_to_config/   -> symlinked to ~/.config/
    symlinked_to_espanso/  -> symlinked to espanso match dir
    manual_install/        -> Alfred workflows, fonts, iTerm profile, KM macros
    xcode_themes/          -> Monokai Xcode color themes
    Brewfile               -> Homebrew packages

## Acknowledgements

Thanks to [nicknisi](https://github.com/nicknisi/dotfiles) for his great vim + tmux talk inspiring me to share my own dotfiles.
Thanks to [ajmalsiddiqui](https://github.com/ajmalsiddiqui/dotfiles) for his bootstrap code.
