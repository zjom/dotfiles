# Composite node: the dev shells in ../../shells. You enter a dev shell with F12
# or with the `use flake` command of direnv. This node contains only the glue
# between fish, fzf, fd, direnv and git.
{ config, ... }:
{
  nodes.devshell =
    { pkgs, ... }:
    {
      imports = with config.nodes; [
        fish
        fzf
        fd
        direnv
        git
      ];

      entry = "fish";

      # git must never commit the cache directories of direnv.
      wrappers.git.settings.core.excludesFile = "${pkgs.writeText "gitignore" ".direnv/\n"}";

      wrappers.fish.configFile.content = ''
        function activate_dev_shell --description "Activate a dev shell"
            # The checkout of this repository on each host.
            set -l flake_root ~/dotfiles
            set -l shell (fd --type f --extension nix . $flake_root/shells --exec echo '{/.}' \
                          | sort \
                          | fzf --prompt='dev shell ⚡ ' --height=40% --reverse --border)

            if test -n "$shell"
                # nix develop sets $SHELL to the bash of the dev shell. Each
                # program that starts from here (most importantly tmux) gets
                # that value. Thus, pass the real login shell to the dev shell.
                set -l outer_shell $SHELL
                nix develop "$flake_root#$shell" -c env SHELL=$outer_shell fish
            else
                echo "No dev shell selected."
            end
        end

        if status is-interactive
            for mode in default insert
                bind -M $mode f12 activate_dev_shell repaint
            end
        end
      '';
    };
}
