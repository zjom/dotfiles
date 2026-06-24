# --- Navigation Functions ---

# Open ranger and cd the shell to the last visited directory on quit.
function ranger_cd() {
    local tmp="$(mktemp)"
    command ranger --choosedir="$tmp" -- "${@:-$PWD}"
    if [[ -f "$tmp" ]]; then
        local dir="$(cat "$tmp")"
        [[ -n "$dir" && "$dir" != "$PWD" ]] && cd -- "$dir"
        rm -f "$tmp"
    fi
}

# Navigate in ranger, then open/connect a tmux session in the chosen directory.
function ranger_sesh() {
    local tmp="$(mktemp)"
    command ranger --choosedir="$tmp" -- "${@:-$PWD}"
    local dir
    [[ -f "$tmp" ]] && dir="$(cat "$tmp")"
    rm -f "$tmp"
    [[ -z "$dir" ]] && return
    sesh connect "$dir"
}

function open_in_nvim() {
    local query="${1:-}"
    local result=$(fd --type f --hidden --follow --exclude=.git --exclude=node_modules --exclude=.venv  --exclude=.DS_Store . | fzf  --query "$query"  --preview="fzf-preview.sh {}" --bind 'focus:transform-header:file --brief {}')

    if [[ -n "$result" ]]; then
        nvim "$result"
    else
        echo "No file selected."
    fi
}

function open_in_nvim_rg() {
    local query="${1:-}"
    local result=$(rg -l --smart-case --hidden "$query" | fzf --preview="fzf-preview.sh {}" --bind 'focus:transform-header:file --brief {}')
    if [[ -n "$result" ]]; then
        nvim "$result"
    else
        echo "No file selected."
    fi
}

# --- Sesh (Session Manager) Functions ---

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

function sesh-all() {
    {
        sesh connect "$(
  sesh list --icons | fzf-tmux -p 80%,70% \
    --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
    --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
    --bind 'tab:down,btab:up' \
    --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
    --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
    --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
    --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
    --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
    --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
    --preview-window 'right:55%' \
    --preview 'sesh preview {}'
)"
    }
}

function quick-run-repl() {
    zle -M "Run: (e)lixir, (j)avascript, (n)ushell, (p)ython"
    zle -R  # force the status line to paint before we block on read

    # Read exactly one key into the variable $key
    local key
    read -k key

    # Clear the prompt message
    zle -M ""

    case $key in
        p)
            # Insert command and run it
            BUFFER="python3"
            zle accept-line
            ;;
        j)
            BUFFER="node"
            zle accept-line
            ;;
        e)
            BUFFER="iex"
            zle accept-line
            ;;
        n)
            BUFFER="nu"
            zle accept-line
            ;;
        *)
            # Handle invalid keys gracefully
            zle -M "Cancelled/Unknown key: $key"
            ;;
    esac
}
zle -N quick-run-repl
