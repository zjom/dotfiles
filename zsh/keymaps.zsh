# --- Keymaps ---
# sesh
zle     -N             sesh-sessions
bindkey -M emacs '\es' sesh-sessions
bindkey -M vicmd '\es' sesh-sessions
bindkey -M viins '\es' sesh-sessions

zle     -N             sesh-all
bindkey -M emacs '\eS' sesh-all
bindkey -M vicmd '\eS' sesh-all
bindkey -M viins '\eS' sesh-all
