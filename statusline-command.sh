#!/bin/sh
input=$(cat)

# ── data extraction ──────────────────────────────────────────────────────────

cwd=$(echo "$input" | jq -r '.workspace.current_dir')
dir=$(basename "$cwd")

branch=""
dirty=""
if git -C "$cwd" rev-parse --no-optional-locks --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null)" ]; then
    dirty="✗"
  fi
fi

used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hr=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# ── color helpers ─────────────────────────────────────────────────────────────
# reset, bold, dim
RST='\033[0m'
DIM='\033[2m'
BOLD='\033[1m'

# foreground colors
GREEN='\033[32m'
CYAN='\033[36m'
RED='\033[31m'
YELLOW='\033[33m'
BLUE='\033[34m'
WHITE='\033[37m'

# ── helper: colored badge ─────────────────────────────────────────────────────
# badge <label> <value> <value_color>
badge() {
  label="$1"
  value="$2"
  color="$3"
  printf " ${DIM}[${RST}${DIM}${BOLD}%s${RST}${DIM}:${RST}${color}%s${RST}${DIM}]${RST}" "$label" "$value"
}

# ── helper: usage badge with dynamic color ────────────────────────────────────
# usage_badge <label> <pct_float>
usage_badge() {
  label="$1"
  pct="$2"
  val=$(printf '%.0f' "$pct")
  # green < 50, yellow 50-79, red >= 80
  if [ "$val" -ge 80 ]; then
    col="$RED"
  elif [ "$val" -ge 50 ]; then
    col="$YELLOW"
  else
    col="$GREEN"
  fi
  badge "$label" "${val}%" "$col"
}

# ── render ────────────────────────────────────────────────────────────────────

# green arrow  (matches robbyrussell / kamranahmedse style)
printf "${BOLD}${GREEN}➜${RST}  "

# cyan directory name
printf "${BOLD}${CYAN}%s${RST}" "$dir"

# git segment:  git:(branch) ✗
if [ -n "$branch" ]; then
  printf " ${DIM}${BLUE}git:(${RST}${RED}%s${DIM}${BLUE})${RST}" "$branch"
  if [ -n "$dirty" ]; then
    printf " ${YELLOW}%s${RST}" "$dirty"
  fi
fi

# metric badges
if [ -n "$used" ]; then
  usage_badge "ctx" "$used"
fi

if [ -n "$five_hr" ]; then
  usage_badge "5h" "$five_hr"
fi

if [ -n "$seven_day" ]; then
  usage_badge "7d" "$seven_day"
fi

printf '\n'
