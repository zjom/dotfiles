{ config, pkgs, ... }:

{
  home.username = "zi";
  home.homeDirectory = "/home/zi";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    ripgrep
    fd
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
  ];

  programs.git = {
    enable = true;
    settings.user = {
      name = "Zihan Jin";
      email = "admin@zihanjin.com";
    };
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
}
