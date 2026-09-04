{ config, pkgs, ... }:

let
  # Configs live in the dotfiles repo and are symlinked out of the nix store so they
  # stay writable (tpm clones into tmux/plugins, vim.pack writes its lockfile) and
  # editable without a rebuild.
  dotfiles = "${config.home.homeDirectory}/projects/dotfiles";
in
{
  home.username = "zi";
  home.homeDirectory = "/home/zi";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    bat
    neovim
    fzf
    gcc
    claude-code
    tmux
    tree-sitter
    nodejs_26
    unzip
    rustc
    cargo
    rust-analyzer
    rustfmt
    clippy
    clang-tools # clangd, clang-format
    nixfmt
    stow
  ];

  xdg.configFile = {
    "tmux".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/tmux/.config/tmux";
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/nvim/.config/nvim";
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "Zihan Jin";
      email = "admin@zihanjin.com";
    };
  };

  programs.ripgrep = {
    enable = true;
    arguments = [
      "--hidden"
      "--smart-case"
      "--glob=!.git/*"
      "--glob=!node_modules/*"
      "--glob=!.venv/*"
      "--glob=!venv/*"
      "--glob=!.DS_Store"
      "--glob=!.git/*"
    ];
  };

  programs.fd = {
    enable = true;
    ignores = [
      ".git"
      ".jj"
      "node_modules"
      ".venv"
      "venv"
    ];
  };

  programs.eza = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.lazygit = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      export EDITOR=nvim
    '';
    shellAliases = {
      ls = "eza";
      rebuild = "sudo nixos-rebuild switch";
      clean = "sudo nix-collect-garbage -d";
      c = "clear";
      lg = "lazygit";
    };
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };
}
