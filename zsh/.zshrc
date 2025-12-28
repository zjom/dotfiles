# --- Environment & Path ---
ZSH_CONFIG_DIR="${HOME}/dotfiles/zsh"

if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

autoload -Uz compinit

for dump in ~/.zcompdump(N.mh+24); do
    compinit
done

compinit -C

zstyle ':completion:*' menu yes select

if [[ "${terminfo[kcbt]}" != "" ]]; then
    bindkey "${terminfo[kcbt]}" reverse-menu-complete   # [Shift-Tab] - move through the completion menu backwards
fi

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
eval "$(mise activate)"
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
source <(fzf --zsh)

# --- Plugins (Syntax Highlighting / Autosuggestions) ---
if type brew &>/dev/null; then
    source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# --- Configuration ---
[[ -f "${ZSH_CONFIG_DIR}/functions.zsh" ]] && source "${ZSH_CONFIG_DIR}/functions.zsh"
[[ -f "${ZSH_CONFIG_DIR}/aliases.zsh" ]] && source "${ZSH_CONFIG_DIR}/aliases.zsh"
[[ -f "${ZSH_CONFIG_DIR}/keymaps.zsh" ]] && source "${ZSH_CONFIG_DIR}/keymaps.zsh"

