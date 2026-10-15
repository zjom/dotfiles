# Go toolchain, with gopls.
#   nix develop '~/dotfiles#go'
{ pkgs }:

pkgs.mkShell {
  name = "go-dev";

  packages = with pkgs; [
    go
    gopls
    gotools # goimports, gorename, callgraph and other tools
    gofumpt
    delve
  ];

  # Keep the module cache and the build cache of each project out of ~/go. Thus,
  # the global GOPATH contains no files after you exit the shell.
  shellHook = ''
    export GOPATH="$PWD/.go"
    export PATH="$GOPATH/bin:$PATH"
    echo "$(go version | cut -d' ' -f3-4) | gopls | delve"
  '';
}
