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
    zoxide
    fzf
    gcc
    eza
    claude-code
    tmux
    tree-sitter
    nodejs_26
  ];

  programs.git = {
    enable = true;
    settings.user = {
      name = "Zihan Jin";
      email = "admin@zihanjin.com";
    };
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      export EDITOR=nvim
      eval "$(zoxide init bash)"
    '';
    shellAliases = {
      ls = "eza";
      rebuild = "sudo nixos-rebuild switch";
      clean = "sudo nix-collect-garbage -d";
      c = "clear";
    };
  };
}
