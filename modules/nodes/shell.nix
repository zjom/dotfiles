# Composite node: fish and tmux as one session, with sesh to pick sessions.
# Owns only the glue between them.
{ config, ... }:
{
  nodes.shell = {
    imports = with config.nodes; [
      fish
      tmux
      sesh
      zoxide
      fzf
    ];

    entry = "fish";

    wrappers.fish = {
      shellAliases.tm = "tmux";

      # fzf's shell bindings open in a tmux popup when inside tmux.
      env.FZF_TMUX = "1";

      configFile.content = ''
        # A function rather than an alias: the wrapper writes aliases in double
        # quotes, which would run the picker when the alias is defined.
        function s --description "Pick any sesh session with fzf and connect to it"
            sesh connect (sesh list --icons | fzf --ansi)
        end

        function sesh_sessions --description "Pick a session with fzf in the current pane"
            set -l session (sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
            commandline -f repaint
            test -z "$session"; and return
            sesh connect $session
        end

        # Kept in sync with the `c-o` binding below.
        function sesh_all --description "The full sesh picker, in a tmux popup"
            set -l session (
              sesh list --icons | fzf-tmux -p 80%,70% \
                --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
                --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^r rename ^f find' \
                --bind 'tab:down,btab:up' \
                --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
                --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
                --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
                --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
                --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
                --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
                --bind 'ctrl-r:execute(printf "Rename %s to: " {2..}; read name; test -n "$name" && tmux rename-session -t {2..} "$name")+change-prompt(⚡  )+reload(sesh list --icons)' \
                --preview-window 'right:55%' \
                --preview 'sesh preview {}'
            )
            commandline -f repaint
            test -z "$session"; and return
            sesh connect $session
        end

        if status is-interactive
            for mode in default insert
                bind -M $mode alt-s sesh_sessions repaint
                bind -M $mode alt-S sesh_all repaint
            end
        end
      '';
    };

    wrappers.tmux.configAfter = ''
      # tmux seeds default-shell from $SHELL when the server starts, and `nix develop`
      # exports $SHELL as the dev shell's own bash -- so a server first launched from
      # inside one hands bash to every later pane, window and session. Pin fish.
      run-shell 'f=$(command -v fish) && tmux set-option -g default-shell "$f"'

      # Sesh session switcher, kept in sync with fish's sesh_all.
      bind "c-o" run-shell "sesh connect \"$(
        sesh list --icons | fzf-tmux -p 80%,70% \
          --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
          --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^r rename ^f find' \
          --bind 'tab:down,btab:up' \
          --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
          --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
          --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
          --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
          --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
          --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
          --bind 'ctrl-r:execute(printf \"Rename %s to: \" {2..}; read name; test -n \"\$name\" && tmux rename-session -t {2..} \"\$name\")+change-prompt(⚡  )+reload(sesh list --icons)' \
          --preview-window 'right:55%' \
          --preview 'sesh preview {}'
      )\""
    '';
  };
}
