# Command line tools that are configured here rather than in the dotfiles
# checkout, because Home Manager also has to wire their shell integration.
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
  programs = {
    bat.enable = true;

    # `use flake` in an .envrc loads a dev shell on cd. nix-direnv caches the
    # shell so it is not rebuilt on every entry.
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    dprint = {
      enable = true;
      settings = {
        plugins = map (plugin: "${plugin}/plugin.wasm") (
          with pkgs.dprint-plugins;
          [
            dprint-plugin-json
            dprint-plugin-markdown
            dprint-plugin-toml
            g-plane-pretty_yaml
          ]
        );
        excludes = map (dir: "**/${dir}") noise ++ [
          "**/*-lock.json"
          "**/flake.lock"
        ];
        json = { };
        markdown = { };
        toml = { };
        yaml = { };
      };
    };

    eza = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    fd = {
      enable = true;
      ignores = noise;
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      tmux.enableShellIntegration = true;

      colors = {
        fg = "#f8f8f2";
        bg = "#0e1419";
        hl = "#e11299";
        "fg+" = "#f8f8f2";
        "bg+" = "#44475a";
        "hl+" = "#e11299";
        info = "#f1fa8c";
        prompt = "#50fa7b";
        pointer = "#ff79c6";
        marker = "#ff79c6";
        spinner = "#a4ffff";
        header = "#6272a4";
      };

      defaultOptions = [
        "--cycle"
        "--pointer=▎"
        "--marker=▎"
        "--walker-skip=${builtins.concatStringsSep "," noise}"
      ];
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

    starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        format = "$username$hostname$directory$git_branch$git_state$git_status$cmd_duration$line_break$python$character";
        directory = {
          style = "blue";
        };
        character = {
          success_symbol = "[❯](purple)";
          error_symbol = "[❯](red)";
          vimcmd_symbol = "[❮](green)";
        };
        git_branch = {
          format = "[$branch]($style)";
          style = "bright-black";
        };
        git_status = {
          format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
          style = "cyan";
          conflicted = "​";
          untracked = "​";
          modified = "​";
          staged = "​";
          renamed = "​";
          deleted = "​";
          stashed = "≡";
        };
        git_state = {
          format = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
          style = "bright-black";
        };
        cmd_duration = {
          format = "[$duration]($style) ";
          style = "yellow";
        };
        python = {
          format = "[$virtualenv]($style) ";
          style = "bright-black";
        };
      };
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
  };
}
