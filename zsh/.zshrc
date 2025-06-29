eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
source <(fzf --zsh)

alias ls='eza --icons always'
alias tree='eza --icons always --tree '
alias t='touch'
alias c='clear'
alias q='exit'
alias lg='lazygit'
alias vim='nvim'
alias tm='tmux -2'
alias cat='bat'

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

if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit
fi


source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

export XDG_CONFIG_HOME="${HOME}/.config"

setopt EXTENDED_GLOB

export PATH=$PATH:~/go/bin

eval "$(mise activate)"
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"

source <(jj util completion zsh)

function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
    zle reset-prompt > /dev/null 2>&1 || true
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}

zle     -N             sesh-sessions
bindkey -M emacs '\es' sesh-sessions
bindkey -M vicmd '\es' sesh-sessions
bindkey -M viins '\es' sesh-sessions
