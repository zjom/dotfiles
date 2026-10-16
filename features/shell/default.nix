# The shell: fish and tmux as one session, sesh to select sessions, eza to list
# files, and the prompt.
{ config, inputs, ... }:
{
  nodes.shell =
    { pkgs, ... }:
    let
      # The full sesh picker, for the alt-S binding of fish and the c-o binding
      # of tmux. The wrapped fzf, fd and tmux come from PATH.
      sesh-pick = pkgs.writeShellApplication {
        name = "sesh-pick";
        # fzf expands the $name of the ctrl-r binding, not this script.
        excludeShellChecks = [ "SC2016" ];
        text = ''
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
        '';
      };

      doen = inputs.doen.packages.${pkgs.stdenv.hostPlatform.system}.default;

    in
    {
      imports = with config.nodes; [
        fish
        tmux
        fzf
        fd
        eza
      ];

      packages = [
        doen
        pkgs.sesh
        pkgs.starship
        pkgs.zoxide
        sesh-pick
      ];

      entry = "fish";

      wrappers.fish = {
        shellAliases = {
          tm = "tmux";
          ls = "eza";
          ll = "eza -l";
          la = "eza -a";
          lla = "eza -la";
          lt = "eza --tree";
          tree = "eza --tree";
        };

        # Inside tmux, the shell bindings of fzf open in a tmux popup.
        env.FZF_TMUX = "1";

        configFile.content = ''
          if status is-interactive
              zoxide init fish | source

              if test "$TERM" != dumb
                  starship init fish | source
              end
          end

          # This definition is a function, not an alias. The wrapper writes
          # aliases in double quotes. With double quotes, the shell runs the
          # picker when it defines the alias.
          function s --description "Pick any sesh session with fzf and connect to it"
              sesh connect (sesh list --icons | fzf --ansi)
          end

          function sesh_sessions --description "Pick a session with fzf in the current pane"
              set -l session (sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
              commandline -f repaint
              test -z "$session"; and return
              sesh connect $session
          end

          function sesh_all --description "The full sesh picker, in a tmux popup"
              set -l session (sesh-pick)
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
        # When the tmux server starts, tmux sets default-shell from $SHELL.
        # `nix develop` sets $SHELL to the bash of the dev shell. Thus, if the
        # server starts inside a dev shell, all later panes, windows and sessions
        # get bash. This setting pins fish.
        run-shell 'f=$(command -v fish) && tmux set-option -g default-shell "$f"'

        bind "c-o" run-shell "sesh connect \"$(sesh-pick)\""
      '';
    };
}
