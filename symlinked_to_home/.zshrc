if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

export EDITOR=/usr/bin/vim
export VISUAL=/usr/bin/vim

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
alias gpr='git pr'
alias pi='pod install'
alias gfm='git fetch origin master:master'
alias gfmr='gfm && git rebase master'
alias grc='git rebase --continue'
alias ga.='git add .'
alias garc='git add .; git rebase --continue'

alias rmdd='rm -rf $HOME/Library/Developer/Xcode/DerivedData'

source ~/.dropboxrc

#Functions
function cd {
  builtin cd "$@" && ls -F
}

function simVideo() {
  xcrun simctl io booted recordVideo "$@"
}

function gco() {
  if [[ $1 =~ ^- ]]; then
    checkoutWithOptions $@
  else
    checkoutWithOptions "" $@
  fi
}

function checkoutWithOptions() {
  if [[ "$2" == "master" ]]; then
    git checkout $@
  else
    git checkout $1 "dbapp-ios/jboulter/$2"
  fi
}

function gp() {
  plannerRegex=".*Planner-iOS$";
  if [[ ! "$PWD" =~ $plannerRegex ]] || (echo "Running tests before pushing" && rpt); then
    echo "Pushing";
    git push "$@";
  else
    tput setaf 1;
    echo "Did not push changes due to failed tests";
    tput sgr0;
  fi

}

function rpt() {
  set -o pipefail && xcodebuild \
    -parallelizeTargets \
    -UseNewBuildSystem=YES \
    -workspace Planner.xcworkspace \
    -scheme Planner-Test \
    -configuration Test \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone Xʀ,OS=latest' \
    test | xcpretty --color
}

function packageArchive() {
  set -x
  incrementBuildNumbers $1

  xcodebuild \
  -parallelizeTargets \
  -UseNewBuildSystem=YES \
  -workspace Planner.xcworkspace \
  -scheme Planner-Release \
  -configuration Release \
  -sdk iphoneos \
  archive \
  -archivePath ~/code/PlannerReleases/$1/Planner.xcarchive \
  | xcpretty --color

  copyDistributionStuff $1
  zipArchive $1
  set +x
}

function incrementBuildNumbers() {
  #pushd ~/code/Planner-iOS
  currentTime=`date +'%y%m%d%H'`
  agvtool new-marketing-version $1
  agvtool new-version -all 1.1.$currentTime
  #popd
}

function copyDistributionStuff() {
  cp ~/code/Planner-iOS/Signing/Microsoft_Planner_Distribution.mobileprovision ~/code/PlannerReleases/$1/Microsoft_Planner_Distribution.mobileprovision
  cp ~/code/Planner-iOS/Signing/exportOptions.plist ~/code/PlannerReleases/$1/exportOptions.plist
}

function zipArchive() {
  pushd ~/code/PlannerReleases/$1/
  zip -r Planner_$1.zip * -x "*.DS_Store"
  popd
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

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#from repo_setup
export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-11.jdk/Contents/Home"
eval "$(pyenv init -)"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$HOME/.pyenv/shims:$PATH"


# From repo_setup:
export ANDROID_HOME="/Users/jboulter/Library/Android/sdk"
export ANDROID_NDK_HOME="/Users/jboulter/Library/Android/ndk"
export ANDROID_NDK="/Users/jboulter/Library/Android/ndk"
export PATH="/Users/jboulter/Library/Android/sdk/platform-tools:/Users/jboulter/Library/Android/sdk/tools:/Users/jboulter/Library/Android/ndk:$PATH"

# rbenv
eval "$(rbenv init - zsh)"


# load tooldir completions
fpath=(~/.zsh/completion $fpath)
autoload -U compinit
compinit

export PATH="/usr/local/opt/php@7.4/bin:$PATH"
export PATH="/usr/local/opt/php@7.4/sbin:$PATH"
export PATH="/usr/local/homebrew/sbin:$PATH"

eval "$(/opt/homebrew/bin/brew shellenv)"
