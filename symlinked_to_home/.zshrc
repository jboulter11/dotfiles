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
#export CLICOLOR=1
export TERM=xterm-256color

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

alias rmdd='rm -rf $HOME/Library/Developer/Xcode/DerivedData'

source ~/.dropboxrc

#Functions
function cd {
  builtin cd "$@" && ls -F
}

function simVideo() {
  xcrun simctl io booted recordVideo "$@"
}

# altool
PATH=$PATH:/Applications/Xcode.app/Contents/Applications/Application\ Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Support/

function killCoreAudio() {
    sudo launchctl stop com.apple.audio.coreaudiod && sudo launchctl start com.apple.audio.coreaudiod
}

# Chrome
function chrome() {
  open -na "Google Chrome" --args $@
}

function incognito() {
  open -na "Google Chrome" --args --incognito $@
}

function mkBuck() {
    echo "load(\"//BuckRules:buck_rule_macros.bzl\", \"first_party_lib\")\n\n" >| "$1/BUCK"
    vim $1/BUCK
}

function buckproj() {
    output=$(buck project --combined-project --without-dependencies-tests --show-output $@)
    file=$(echo $output | sed -En 's/^.*(buck\-out\/gen\/.+)$/\1/p')
    open $file
}

function replace() {
  local pattern="$1"
  local replacement="$2"
  local escaped_pattern
  local escaped_replacement
  escaped_pattern=$(escape_for_sed "$pattern")
  escaped_replacement=$(escape_for_sed "$replacement")

  if [[ "$3" == "-s" ]]; then
    rg "$escaped_pattern" --files-with-matches | xargs sed -i "" "s/$escaped_pattern/$escaped_replacement/g"
  else
    rg "$escaped_pattern" --files-with-matches | xargs sed -i "" "s/$escaped_pattern/$escaped_replacement/g" | tee /dev/tty
  fi

  find . -type f -name "*.bak" -delete
}

function escape_for_sed() {
  echo "$1" | sed 's/[\^\/]/\\&/g'
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# From repo_setup:
export ANDROID_HOME="/Users/jboulter/Library/Android/sdk"
export ANDROID_NDK_HOME="/Users/jboulter/Library/Android/ndk"
export ANDROID_NDK="/Users/jboulter/Library/Android/ndk"
export PATH="/Users/jboulter/Library/Android/sdk/platform-tools:/Users/jboulter/Library/Android/sdk/tools:/Users/jboulter/Library/Android/ndk:$PATH"

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
# From repo_setup:
export JAVA_HOME="/Users/jboulter/.dbx_jdk/zulu17.42.19-ca-jdk17.0.7-macosx_aarch64"
alias td="./td"
# load tooldir completions
fpath+=(~/.zsh/completion)
autoload -U compinit
compinit
eval "$(pyenv init -)"
export PATH="/Users/jboulter/.local/share/sentry-devenv/bin:$PATH"


eval "$(direnv hook zsh)"


# From repo_setup:
export PATH="$HOME/.pyenv/shims:$PATH"