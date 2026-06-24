if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

export EDITOR=nvim
export VISUAL=nvim

autoload -Uz promptinit
promptinit
prompt jim

# Customize to your needs...
##Start env config

#Aliases
alias gst='git status'
alias gpl='git pull'
alias gb='git branch'
alias gac='git add .; git commit -m'
alias gd='git diff'
alias gfm='git fetch origin main:main'
alias gfmr='gfm && git rebase main'
alias grc='git rebase --continue'
alias ga.='git add .'
alias garc='git add .; git rebase --continue'
alias gco='git checkout'
alias gmt='git mergetool'
gdt() {
  git add --intent-to-add -A
  git difftool "$@"
}

gdtm() {
  git add --intent-to-add -A
  git difftool $(git merge-base main HEAD)
}

alias rmdd='rm -rf $HOME/Library/Developer/Xcode/DerivedData'

alias lg='lazygit'
alias nv='neovide --fork'
alias pl='park'
alias plc='park --clean'

export PATH="$(dirname "$(dirname "$(readlink "$HOME/.zshrc")")")/scripts:$PATH"
source ~/.dropboxrc

function cd {
    builtin cd "$@" && ls -F
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# rbenv
eval "$(rbenv init - zsh)"

eval "$(/opt/homebrew/bin/brew shellenv)"
# load tooldir completions
fpath+=(~/.zsh/completion)
autoload -U compinit
compinit -u
_comp_options+=(globdots)

eval "$(direnv hook zsh)"

export PATH="$HOME/.local/bin:$PATH"

# bun completions
[ -s "/Users/jim/.bun/_bun" ] && source "/Users/jim/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Added by git-ai installer on Thu Jun 18 12:42:23 PDT 2026
export PATH="/Users/jboulter/.git-ai/bin:$PATH"
