# Packages wanted on every host. Host-only packages go in hosts/<name>/home.nix;
# the list is merged, so a host appends rather than replaces.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    claude-code
    file
    gcc
    github-cli
    neovim
    nixfmt
    nodejs
    python3
    tmux
    tree-sitter
    unzip
  ];
}
