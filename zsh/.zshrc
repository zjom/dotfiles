eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
source <(fzf --zsh)

alias ls='eza --icons'
alias tree='eza --icons --tree'
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

export PATH=$PATH:~/go/bin

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

setopt EXTENDED_GLOB


eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
