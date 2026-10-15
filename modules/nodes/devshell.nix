# Composite node: the dev shells in ../../shells, entered with F12 or by
# direnv's `use flake`. Owns only the glue between fish, fzf, fd, direnv and
# git.
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

      # direnv's cache directories are never worth committing.
      wrappers.git.settings.core.excludesFile = "${pkgs.writeText "gitignore" ".direnv/\n"}";

      wrappers.fish.configFile.content = ''
        function activate_dev_shell --description "Activate a dev shell"
            # The checkout of this repository on every host.
            set -l flake_root ~/dotfiles
            set -l shell (fd --type f --extension nix . $flake_root/shells --exec echo '{/.}' \
                          | sort \
                          | fzf --prompt='dev shell ⚡ ' --height=40% --reverse --border)

            if test -n "$shell"
                # nix develop exports $SHELL as the dev shell's bash. Anything
                # started from here (tmux above all) would inherit it, so carry
                # the real login shell through.
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
