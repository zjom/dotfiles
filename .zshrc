eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
source <(fzf --zsh)

alias ls='eza --icons'
alias t='touch'
alias c='clear'
alias q='exit'
alias lg='lazygit'
alias vim='nvim'
alias tm='tmux -2'
alias cat='bat'

open_in_nvim() {
  local result=$(fzf)

  if [[ -n "$result" ]]; then
    nvim "$result"
  else
    echo "No file selected."
  fi
}

alias nf='open_in_nvim'


if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit
fi

export PATH=$PATH:~/code/go/bin

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '/Users/zihanjin/.opam/opam-init/init.zsh' ]] || source '/Users/zihanjin/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration

# Created by `pipx` on 2024-09-18 02:01:48
export PATH="$PATH:/Users/zihanjin/.local/bin"

setopt EXTENDED_GLOB


[ -f "/Users/zihanjin/.ghcup/env" ] && . "/Users/zihanjin/.ghcup/env" # ghcup-env
export PATH=/Users/zihanjin/edirect:${PATH}
