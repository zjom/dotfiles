# Command line tools that are configured here rather than in the dotfiles
# checkout, because Home Manager also has to wire their shell integration.
{ config, ... }:

let
  inherit (config) colors;
in
{
  homeManager.base =
    { pkgs, ... }:
    let
      # Directories that are never worth searching, walking or listing.
      noise = [
        ".git"
        ".jj"
        "node_modules"
        ".venv"
        "venv"
      ];
    in
    {
      home.sessionVariables.PAGER = "bat";

      programs = {
        bat.enable = true;

        devenv = {
          enable = true;
          enableFishIntegration = true;
          settings = {
            shell = {
              prompt_prefix = false;
            };
            tui = {
              statusline = {
                enabled = false;
              };
            };
          };
        };

        # `use flake` in an .envrc loads a dev shell on cd. nix-direnv caches the
        # shell so it is not rebuilt on every entry.
        direnv = {
          enable = true;
          nix-direnv.enable = true;
          enableGitIntegration = true;
          silent = true;
        };

        eza = {
          enable = true;
          icons = "always";
        };

        fd = {
          enable = true;
          ignores = noise;
        };

        fzf = {
          enable = true;
          tmux.enableShellIntegration = true;
          defaultOptions = [
            "--cycle"
            "--pointer=▎"
            "--marker=▎"
            "--walker-skip=${builtins.concatStringsSep "," noise}"
          ];
          colors = builtins.mapAttrs (_: c: "#${c}") (
            with colors;
            {
              fg = fg;
              bg = bg;
              hl = string;
              "fg+" = fg;
              "bg+" = line;
              "hl+" = string;
              gutter = bg;
              query = fg;
              info = comment;
              border = floatBorder;
              separator = line;
              scrollbar = line;
              prompt = keyword;
              pointer = func;
              marker = plus;
              spinner = warning;
              header = comment;
            }
          );
        };

        lazygit.enable = true;

        ripgrep = {
          enable = true;
          arguments = [
            "--hidden"
            "--smart-case"
            "--glob=!.DS_Store"
          ]
          ++ map (dir: "--glob=!${dir}/*") noise;
        };

        sesh = {
          enable = true;
          enableTmuxIntegration = true;
        };

        starship.enable = true;

        zoxide.enable = true;
      };
    };
}
