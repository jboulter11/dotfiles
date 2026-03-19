#!/bin/zsh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

ln -sfnv "$SCRIPT_DIR/zprezto/prompt_jim_setup" "${ZDOTDIR:-$HOME}"/.zprezto/modules/prompt/functions/prompt_jim_setup

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^((README.md)|(zshrc)|(zpreztorc))(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

chsh -s /bin/zsh
