# nomagic - A Powerline-inspired theme for ZSH
# built from agnoster
# 
# <status> <user> <hostname> <work dir> <prompt>                                                            <current time> <running jobs>
#
### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'

case ${SOLARIZED_THEME:-dark} in
    light) CURRENT_FG='white';;
    *)     CURRENT_FG='235';;
esac

SEGMENT_SEPARATOR=$'\ue0b0'

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else 
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  prompt_segment 235 default "%(!.%{%F{yellow}%}.)%n@%m"
}

# Git: branch/detached head, dirty status
prompt_git() {
  (( $+commands[git] )) || return

  # if current path not a repo, return fast
  if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ]]; then
    return
  fi

  local ref
  ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"

  local PL_BRANCH_CHAR ahead behind
  PL_BRANCH_CHAR=$'\ue725'
  ahead=$(git log --oneline @{upstream}.. 2>/dev/null)
  behind=$(git log --oneline ..@{upstream} 2>/dev/null)
  if [[ -n "$ahead" && -n "$behind" ]]; then
    PL_BRANCH_CHAR=$'\ueafd'
  elif [[ -n "$ahead" ]]; then
    PL_BRANCH_CHAR=$'\u2191'
  elif [[ -n "$behind" ]]; then
    PL_BRANCH_CHAR=$'\u2193'
  fi

  if [[ -n $(git status --porcelain 2>/dev/null) || -n "$ahead" || -n "$behind" ]]; then
    prompt_segment yellow 235
  else
    prompt_segment 79 $CURRENT_FG
  fi
  echo -n "${${ref:gs/%/%%}/refs\/heads\//$PL_BRANCH_CHAR }${mode}"
}


# Dir: current working directory
prompt_dir() {
  prompt_segment blue 235 '%~'
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local -a symbols
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}\u2718"
  [[ $RETVAL -eq 0 ]] && symbols+="%{%F{79}%}\uf42e"
  [[ -n "$symbols" ]] && prompt_segment 235 default "$symbols"
}

prompt_system_icon() {
  local icon
  icon=' \ue712'
  if [[ -e "go.mod" || "$(go list -m)" != "command-line-arguments" ]]; then
    icon='\u202D\uFCD1'
  fi
  prompt_segment 235 yellow "$icon"
}

## Main prompt
build_left_prompt() {
  RETVAL=$?
  prompt_system_icon
  prompt_context
  prompt_dir
  prompt_git
  prompt_status
  prompt_end
  echo
  echo -n "%{%F{red}%}  $ %{%f%}"
}

PROMPT='%{%f%b%k%}$(build_left_prompt) '
RPROMPT='%{%F{blue}%}%D{%T}%{%f%}'