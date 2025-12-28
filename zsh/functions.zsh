# --- Navigation Functions ---

function open_in_nvim() {
    local query="${1:-}"
    local result=$(fd --type f --hidden --follow . | fzf  --query "$query" --walker-skip=.git,node_modules,.venv,venv,.jj --preview="fzf-preview.sh {}" --bind 'focus:transform-header:file --brief {}')

    if [[ -n "$result" ]]; then
        nvim "$result"
    else
        echo "No file selected."
    fi
}

function open_in_nvim_rg() {
    local query="${1:-}"
    local result=$(rg -l --smart-case "$query" | fzf --walker-skip=.git,node_modules,.venv,venv,.jj --preview="fzf-preview.sh {}" --bind 'focus:transform-header:file --brief {}')
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
