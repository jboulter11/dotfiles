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
alias gdt='git difftool'

alias rmdd='rm -rf $HOME/Library/Developer/Xcode/DerivedData'

alias lg='lazygit'
alias nv='neovide --fork'
alias pl='park'

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

function park() {
    local G=$'\033[0;32m' Y=$'\033[0;33m' R=$'\033[0;31m' C=$'\033[0;36m' N=$'\033[0m'

    local worktree_dir
    worktree_dir=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)") || {
        echo "${R}❌ Not in a git repository${N}"
        return 1
    }

    # Determine the main worktree name to detect numbered variants
    local main_worktree
    main_worktree=$(basename "$(cd "$(git rev-parse --git-common-dir)" && cd .. && pwd)")

    local pl_branch
    if [[ "${worktree_dir:l}" == "${main_worktree:l}" ]]; then
        pl_branch="pl"
    elif [[ "${worktree_dir:l}" =~ ^${main_worktree:l}([0-9]+)$ ]]; then
        pl_branch="pl${match[1]}"
    else
        pl_branch="pl-$worktree_dir"
    fi

    echo "🅿️  Parking ${C}${worktree_dir}${N} → ${C}${pl_branch}${N}"

    # Create parking lot branch from main if it doesn't exist
    if ! git show-ref --verify --quiet "refs/heads/$pl_branch"; then
        echo "🌱 Creating ${C}${pl_branch}${N} from main..."
        git checkout -b "$pl_branch" main || return 1
    else
        git checkout "$pl_branch" || return 1
    fi

    # Fetch main and rebase
    echo "📡 Fetching main..."
    git fetch origin main:main || { echo "${Y}⚠️  Fetch failed — parked on ${C}${pl_branch}${N}"; return 0; }

    echo "🔄 Rebasing against main..."
    if git rebase main; then
        echo "${G}✅ Parked on ${C}${pl_branch}${G} (rebased against main)${N}"
    else
        git rebase --abort
        echo "${Y}⚠️  Parked on ${C}${pl_branch}${Y} (rebase aborted due to conflicts)${N}"
    fi
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

# sentry
export PATH="$HOME/.sentry/bin:$PATH"
# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# bun completions
[ -s "/Users/jim/.bun/_bun" ] && source "/Users/jim/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
