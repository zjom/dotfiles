{ pkgs }:

with pkgs;
mkShell {
  name = "c-dev";

  packages = [
    gcc
    gnumake
    cmake
    pkg-config
    just
    just-lsp
    clang-tools # clangd and clang-format
    bear # `bear -- make` writes compile_commands.json for clangd
    meson
    ninja
    gdb
  ]
  # This package is marked as broken on Darwin.
  ++ lib.optional stdenv.hostPlatform.isLinux valgrind;

  shellHook = ''
    echo "$(gcc --version | head -1) | clangd $(clangd --version | grep -o '[0-9]\+\.[0-9.]*' | head -1)"
  '';
}
