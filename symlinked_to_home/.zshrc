if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

export EDITOR=nvim
export VISUAL=nvim

autoload -Uz promptinit
promptinit
prompt sorin

# Customize to your needs...
##Start env config

#Aliases
alias gst='git status'
alias gpl='git pull'
alias gb='git branch'
alias gac='git add .; git commit -m'
alias gd='git diff'
alias pi='pod install'
alias gfm='git fetch origin main:main'
alias gfmr='gfm && git rebase main'
alias grc='git rebase --continue'
alias ga.='git add .'
alias garc='git add .; git rebase --continue'
alias gco='git checkout'
alias gmt='git mergetool'
alias gdt='git difftool'

alias rmdd='rm -rf $HOME/Library/Developer/Xcode/DerivedData'

alias lg='lazygit'
alias nv='neovide --fork'

source ~/.dropboxrc

#Functions
function cd {
    builtin cd "$@" && ls -F
}

function simVideo() {
    xcrun simctl io booted recordVideo "$@"
}

function killCoreAudio() {
    sudo pkill -9 coreaudiod
}

# Chrome
function chrome() {
    open -na "Google Chrome" --args $@
}

function incognito() {
    open -na "Google Chrome" --args --incognito $@
}

function replace() {
  local pattern="$1"
  local replacement="$2"
  local escaped_pattern
  local escaped_replacement
  escaped_pattern=$(escape_for_sed "$pattern")
  escaped_replacement=$(escape_for_sed "$replacement")

  local files
  files=$(rg "$escaped_pattern" --files-with-matches)

  if [[ -z "$files" ]]; then
    echo "No files matched."
    return 1
  fi

  if [[ "$3" != "-s" ]]; then
    echo "$files"
  fi

  echo "$files" | xargs sed -i "" "s/$escaped_pattern/$escaped_replacement/g"

  find . -type f -name "*.bak" -delete
}

function escape_for_sed() {
  echo "$1" | sed 's/[\^\/]/\\&/g'
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# From repo_setup:
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_NDK_HOME="$HOME/Library/Android/ndk"
export ANDROID_NDK="$HOME/Library/Android/ndk"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$ANDROID_NDK:$PATH"

# rbenv
eval "$(rbenv init - zsh)"

# intel
export PATH="/usr/local/opt/php@7.4/bin:$PATH"
export PATH="/usr/local/opt/php@7.4/sbin:$PATH"
export PATH="/usr/local/homebrew/sbin:$PATH"

# m1
export PATH="/opt/homebrew/opt/php@7.4/bin:$PATH"
export PATH="/opt/homebrew/opt/php@7.4/sbin:$PATH"

eval "$(/opt/homebrew/bin/brew shellenv)"
# load tooldir completions
fpath+=(~/.zsh/completion)
autoload -U compinit
compinit -u
_comp_options+=(globdots)
eval "$(pyenv init -)"
export PATH="$HOME/.local/share/sentry-devenv/bin:$PATH"


eval "$(direnv hook zsh)"

export BAZEL=1
# From repo_setup:
export JAVA_HOME="$HOME/.dbx_jdk/zulu21.32.17-ca-fx-jdk21.0.2-macosx_aarch64"
# From repo_setup:
export PATH="$HOME/.pyenv/shims:$PATH"
export PATH="$HOME/.local/bin:$PATH"
<<<<<<< Updated upstream

# sentry
export PATH="$HOME/.sentry/bin:$PATH"
||||||| Stash base
=======
# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# bun completions
[ -s "/Users/jim/.bun/_bun" ] && source "/Users/jim/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
>>>>>>> Stashed changes
