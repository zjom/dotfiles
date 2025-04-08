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
alias rm='rm -i'


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
export PATH="$HOME/.dotnet/tool/:$PATH"
export PATH="/home/zjom/.local/bin:$PATH" #uv

##############
###  Eval  ###
##############
eval "$(fzf --bash)"
eval "$(starship init bash)"
eval "$(zoxide init bash)"
