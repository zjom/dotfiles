# Typst toolchain + tinymist.
#   nix develop '~/dotfiles/nix#typst'
{ pkgs }:

pkgs.mkShell {
  name = "typst-dev";

  packages = with pkgs; [
    typst
    tinymist
    typstyle
  ];

  shellHook = ''
    echo "typst $(typst --version | cut -d' ' -f2) | tinymist"
  '';
}
