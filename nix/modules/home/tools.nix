# Command line tools that are configured here rather than in the dotfiles
# checkout, because Home Manager also has to wire their shell integration.
{ config, pkgs, ... }:

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
      enableFishIntegration = true;
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
      enableFishIntegration = true;
    };

    fd = {
      enable = true;
      ignores = noise;
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
      tmux.enableShellIntegration = true;
      defaultOptions = [
        "--cycle"
        "--pointer=▎"
        "--marker=▎"
        "--walker-skip=${builtins.concatStringsSep "," noise}"
      ];
      colors = builtins.mapAttrs (_: c: "#${c}") (
        with config.my.colors;
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

    starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
