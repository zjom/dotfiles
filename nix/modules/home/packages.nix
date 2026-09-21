# Packages wanted on every host. Host-only packages go in hosts/<name>/home.nix;
# the list is merged, so a host appends rather than replaces.
#
# Language toolchains deliberately do not live here -- they belong to the dev
# shells under nix/shells. The exceptions are the few things Neovim itself
# shells out to: a C compiler for tree-sitter grammars, and the node/python
# providers.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bottom
    claude-code
    file
    gcc
    jq
    neovim
    nixd
    nixfmt
    nodejs
    opencode
    oxfmt
    python3
    ranger
    tombi
    tmux
    tree-sitter
    unzip
    wget
  ];
}
