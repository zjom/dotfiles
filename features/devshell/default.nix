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

          # Without a command, nix develop starts the bash of the dev shell, which
          # has no fish aliases and no fish history. Thus, start fish instead.
          function nix --wraps nix --description "nix, with fish as the shell of nix develop"
              # With one of these flags, nix develop runs a command of its own.
              set -l own_command -c --command --phase --unpack --configure --build --check --install --installcheck -h --help
              set -l wrap (test "$argv[1]" = develop; and echo 1)
              for arg in $argv
                  contains -- $arg $own_command; and set wrap
              end

              if test -n "$wrap"
                  # nix develop sets $SHELL to the bash of the dev shell. Each
                  # program that starts from here (most importantly tmux) gets
                  # that value. Thus, pass the real login shell to the dev shell.
                  # A fish from PATH can be the fish of an old generation.
                  set -l login_shell $SHELL
                  string match -q '*/fish' -- $login_shell; or set login_shell (command -s fish)
                  command nix $argv --command env SHELL=$login_shell $login_shell
              else
                  command nix $argv
              end
          end

          function activate_dev_shell --description "Activate a dev shell"
              # The checkout of this repository on each host.
              set -l flake_root ~/dotfiles
              set -l shell (fd --type f --extension nix . $flake_root/shells --exec echo '{/.}' \
                            | sort \
                            | fzf --prompt='dev shell ⚡ ' --height=40% --reverse --border)

              if test -n "$shell"
                  nix develop "$flake_root#$shell"
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
