# Dev shells: one language toolchain in each file of ../../shells. You enter a
# dev shell with F12, or with `use flake ~/dotfiles#<name>` in an .envrc file.
{ config, lib, ... }:
let
  inherit (config) nodes;
  dir = ../../shells;
in
{
  nodes.devshell =
    { config, pkgs, ... }:
    {
      imports = with nodes; [
        fish
        fzf
        fd
        direnv
        git
      ];

      entry = "fish";

      wrappers.git.settings.core.excludesFile = "${pkgs.writeText "gitignore" ".direnv/\n"}";

      wrappers.fish = {
        # `direnv hook` writes the path of the unwrapped binary into the hook.
        # Thus, the hook gets the configuration of the wrapper from this variable.
        env.DIRENV_CONFIG = dirOf config.wrappers.direnv.constructFiles.direnvrc.outPath;

        configFile.content = ''
          if status is-interactive
              if not functions -q __direnv_export_eval
                  direnv hook fish | source
              end

              if command -q devenv
                  devenv hook fish | source
              end
          end

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
    };

  # devenv keeps its settings in ~/.config/devenv, so devenv is not a node.
  flake.modules.homeManager.base.programs.devenv = {
    enable = true;
    enableFishIntegration = false;
    settings = {
      shell.prompt_prefix = false;
      tui.statusline.enabled = false;
    };
  };

  # Each file in ../../shells is a plain `{ pkgs }:` function, not a module.
  perSystem =
    { pkgs, ... }:
    {
      devShells = lib.mapAttrs' (
        file: _:
        lib.nameValuePair (lib.removeSuffix ".nix" file) (import (dir + "/${file}") { inherit pkgs; })
      ) (builtins.readDir dir);
    };
}
