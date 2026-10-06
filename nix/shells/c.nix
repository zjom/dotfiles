# C toolchain + clangd.
#   nix develop '~/dotfiles/nix#c'
{ pkgs }:

pkgs.mkShell {
  name = "c-dev";

  packages = with pkgs; [
    gcc
    gnumake
    cmake
    pkg-config
    just
    just-lsp
    clang-tools # clangd + clang-format
    bear # `bear -- make` writes compile_commands.json for clangd
    meson
    ninja
    gdb
    valgrind
  ];

  shellHook = ''
    echo "$(gcc --version | head -1) | clangd $(clangd --version | grep -o '[0-9]\+\.[0-9.]*' | head -1)"
  '';
}
