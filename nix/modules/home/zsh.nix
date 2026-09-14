# zsh-only configuration. Everything here is either a zsh builtin (setopt,
# zstyle, zle, bindkey) or a plugin with no bash counterpart; anything that
# could be shared lives in shell.nix instead.
{ ... }:

{
  programs.zsh = {
    # Both were sourced out of the Homebrew prefix before; nixpkgs ships them.
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    history = {
      # xdg.enable moves zsh's dotDir under ~/.config/zsh, which would take the
      # history file with it and orphan the existing one.
      path = "$HOME/.zsh_history";
      size = 10000000;
      save = 10000000;
      extended = true;
      share = true;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      findNoDups = true;
      saveNoDups = true;
    };
  };

  my.shell.zshExtra = ''
    setopt EXTENDED_GLOB   # ^ to negate a pattern, # for repetition.
    setopt CORRECT         # Offer a spelling correction for a mistyped command.
    setopt HIST_REDUCE_BLANKS
    setopt HIST_VERIFY     # Expand a ! history reference onto the line, don't run it.

    zstyle ':completion:*' menu yes select

    # Shift-Tab walks the completion menu backwards.
    if [[ -n "''${terminfo[kcbt]}" ]]; then
      bindkey "''${terminfo[kcbt]}" reverse-menu-complete
    fi

    # Pick a session with fzf in the current pane. Bound to Alt-s.
    sesh-sessions() {
      exec </dev/tty
      exec <&1
      local session
      session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
      zle reset-prompt > /dev/null 2>&1 || true
      [[ -z "$session" ]] && return
      sesh connect "$session"
    }
    zle -N sesh-sessions
    bindkey -M emacs '\es' sesh-sessions
    bindkey -M vicmd '\es' sesh-sessions
    bindkey -M viins '\es' sesh-sessions

    # The full picker, in a tmux popup, with source filters on ^a ^t ^g ^x ^f.
    # Kept in sync with the `c-o` binding in tmux/tmux.conf.
    sesh-all() {
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
    zle -N sesh-all
    bindkey -M emacs '\eS' sesh-all
    bindkey -M vicmd '\eS' sesh-all
    bindkey -M viins '\eS' sesh-all

    # One keypress to drop into a REPL. Bound to F12.
    quick-run-repl() {
      zle -M "Run: (e)lixir, (j)avascript, (n)ushell, (p)ython"
      zle -R  # Paint the status line before we block on read.

      local key
      read -k key
      zle -M ""

      case $key in
        p) BUFFER="python3"; zle accept-line ;;
        j) BUFFER="node";    zle accept-line ;;
        e) BUFFER="iex";     zle accept-line ;;
        n) BUFFER="nu";      zle accept-line ;;
        *) zle -M "Cancelled/Unknown key: $key" ;;
      esac
    }
    zle -N quick-run-repl
    if [[ -n "''${terminfo[kf12]}" ]]; then
      bindkey "''${terminfo[kf12]}" quick-run-repl
    fi

    # Installed outside Nix; source them only where they exist.
    [[ -f ~/.orbstack/shell/init.zsh ]] && source ~/.orbstack/shell/init.zsh 2>/dev/null
    for f in ~/Library/Google/google-cloud-sdk/{path,completion}.zsh.inc; do
      [[ -f "$f" ]] && source "$f"
    done
  '';
}
