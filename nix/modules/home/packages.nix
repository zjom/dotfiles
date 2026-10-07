# Packages wanted on every host. Host-only packages go in hosts/<name>/home.nix;
# the list is merged, so a host appends rather than replaces.
#
# Language toolchains deliberately do not live here -- they belong to the dev
# shells under nix/shells. The exceptions are the few things Neovim itself
# shells out to: a C compiler for tree-sitter grammars, cargo for blink.cmp's
# fuzzy matcher, and the node/python providers.
{ inputs, pkgs, ... }:

{
  home.packages = with pkgs; [
    bottom
    cargo
    claude-code
    file
    gcc
    jq
    man-pages
    markdown-oxide
    neovim
    nixd
    nixfmt
    nodejs
    oxfmt
    python3
    ranger
    tmux
    tombi
    tree-sitter
    unzip
    wget

    # gitignore fetcher, built from its own flake rather than nixpkgs.
    inputs.get-ignore.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
