export XDG_CONFIG_HOME="${HOME}/.config"

export PATH="$PATH:/Users/zihanjin/.local/bin"
export PATH=$PATH:~/go/bin

source ~/.orbstack/shell/init.zsh 2>/dev/null || :

eval "$(/opt/homebrew/bin/brew shellenv)"

