#!/bin/sh
# Claude Code status line with emoji icons
input=$(cat)

# Extract all fields via a single jq call
eval "$(echo "$input" | jq -r '
  @sh "cwd=\(.workspace.current_dir // .cwd // "")",
  @sh "session_id=\(.session_id // "")",
  @sh "model_id=\(.model.id // "")",
  @sh "used_pct=\(.context_window.used_percentage // "")",
  @sh "duration_ms=\(.cost.total_duration_ms // 0 | floor)",
  @sh "lines_added=\(.cost.total_lines_added // 0 | floor)",
  @sh "lines_removed=\(.cost.total_lines_removed // 0 | floor)",
  @sh "wt_name=\(.worktree.name // "")",
  @sh "cost_raw=\(.cost.total_cost_usd // 0)"
')"

# Track per-session baseline so metrics reset on /clear.
# When the session_id changes, we snapshot cumulative values as the new
# baseline and subtract them from all future readings.
if [ -n "$session_id" ]; then
  state_file="/tmp/claude-sl-${session_id}"
  if [ -f "$state_file" ]; then
    read base_cost base_dur base_add base_rm < "$state_file"
    : "${base_cost:=0}" "${base_dur:=0}" "${base_add:=0}" "${base_rm:=0}"
  else
    printf '%s %s %s %s\n' "$cost_raw" "$duration_ms" "$lines_added" "$lines_removed" > "$state_file"
    base_cost="$cost_raw" base_dur="$duration_ms" base_add="$lines_added" base_rm="$lines_removed"
  fi
  duration_ms=$(( duration_ms - base_dur ))
  lines_added=$(( lines_added - base_add ))
  lines_removed=$(( lines_removed - base_rm ))
  cost_usd=$(awk -v raw="$cost_raw" -v base="$base_cost" 'BEGIN { printf "%.2f", raw - base }')
else
  cost_usd=$(awk -v raw="$cost_raw" 'BEGIN { printf "%.2f", raw }')
fi

# Shorten path (replace $HOME with ~)
home="$HOME"
short_cwd="${cwd/#$home/\~}"

# Git branch
git_branch=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# Format duration from ms to human readable
if [ "$duration_ms" -gt 0 ] 2>/dev/null; then
  total_s=$((duration_ms / 1000))
  if [ "$total_s" -ge 3600 ]; then
    h=$((total_s / 3600))
    m=$(( (total_s % 3600) / 60 ))
    duration="${h}h${m}m"
  elif [ "$total_s" -ge 60 ]; then
    m=$((total_s / 60))
    s=$((total_s % 60))
    duration="${m}m${s}s"
  else
    duration="${total_s}s"
  fi
else
  duration="0s"
fi

# Colors
blue='\033[34m'
green='\033[32m'
yellow='\033[33m'
red='\033[31m'
cyan='\033[36m'
gold='\033[38;5;220m'
dim='\033[2m'
reset='\033[0m'

# Build status line
line="$(printf "${blue}📂 %s${reset}" "$short_cwd")"

if [ -n "$git_branch" ]; then
  line="$line $(printf "${green}🌿 %s${reset}" "$git_branch")"
fi

if [ -n "$wt_name" ]; then
  line="$line $(printf "${yellow}🌲 %s${reset}" "$wt_name")"
elif [ -n "$cwd" ] && git -C "$cwd" rev-parse --show-toplevel > /dev/null 2>&1; then
  main_wt=$(basename "$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)")
  line="$line $(printf "${yellow}🌲 %s${reset}" "$main_wt")"
fi

line="$line $(printf "${dim}│${reset}")"

if [ -n "$model_id" ]; then
  line="$line $(printf "${cyan}🧠 %s${reset}" "$model_id")"
fi

if [ -n "$used_pct" ] && [ "$used_pct" != "null" ]; then
  ctx_color="$green"
  pct_int="${used_pct%%.*}"
  if [ "$pct_int" -ge 80 ] 2>/dev/null; then
    ctx_color="$red"
  elif [ "$pct_int" -ge 50 ] 2>/dev/null; then
    ctx_color="$yellow"
  fi
  line="$line $(printf "${ctx_color}📊 %s%%${reset}" "$used_pct")"
fi

line="$line $(printf "${gold}💰 \$%s${reset}" "$cost_usd")"
line="$line $(printf "⏱️ %s" "$duration")"
line="$line $(printf "✏️ ${green}+%s${reset}/${red}-%s${reset}" "$lines_added" "$lines_removed")"

printf "%b\n" "$line"
