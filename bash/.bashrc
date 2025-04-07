#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#################
###  Aliases  ###
#################
alias c='clear'
alias q='exit'

alias tm='tmux -2'
alias ls='exa --color=auto --icons'
alias cat='bat'
alias vim='nvim'


###############
###  Utils  ###
###############
open_in_nvim() {
  local query="${1:-}"
  local result=$(fzf --walker-skip=.git,node_modules,.venv,venv --query "$query" --preview="fzf-preview.sh {}" --bind 'focus:transform-header:file --brief {}')

  if [[ -n "$result" ]]; then
    nvim "$result"
  else
    echo "No file selected."
  fi
}

alias nf='open_in_nvim'

open_in_nvim_rg() {
  local query="${1:-}"
  local result=$(rg -l --smart-case "$query" | fzf -m --walker-skip=.git,node_modules,.venv,venv --preview="fzf-preview.sh {}" --bind 'focus:transform-header:file --brief {}')
  if [[ -n "$result" ]]; then
    nvim "$result"
  else
    echo "No file selected."
  fi
}
alias nr='open_in_nvim_rg'


##############
###  Path  ###
##############
export PATH="$HOME/go/bin/:$PATH"
export PATH="$HOME/bin/:$PATH"
export PATH="$HOME/.cargo/bin/:$PATH"
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"


##############
###  Eval  ###
##############
. <(asdf completion bash)
eval "$(fzf --bash)"
eval "$(starship init bash)"
eval "$(zoxide init bash)"
