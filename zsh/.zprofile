export XDG_CONFIG_HOME="${HOME}/.config"

export PATH="$PATH:/Users/zihanjin/.local/bin"
export PATH=$PATH:~/go/bin

# pnpm
export PNPM_HOME="/Users/zihanjin/Library/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

source ~/.orbstack/shell/init.zsh 2>/dev/null || :

eval "$(/opt/homebrew/bin/brew shellenv)"

