#!/bin/zsh

git clone --recursive https://github.com/jboulter11/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

cp zprezto/prompt_jim_setup "${ZDOTDIR:-$HOME}"/.zprezto/modules/prompt/functions/prompt_jim_setup

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^((README.md)|(zshrc)|(zpreztorc))(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

chsh -s /bin/zsh
