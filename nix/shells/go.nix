# Go toolchain + gopls.
#   nix develop '~/dotfiles/nix#go'
{ pkgs }:

pkgs.mkShell {
  name = "go-dev";

  packages = with pkgs; [
    go
    gopls
    gotools # goimports, gorename, callgraph, ...
    gofumpt
    delve
  ];

  # Keep per-project module and build caches out of ~/go, so a shell exit
  # leaves nothing behind on the global GOPATH.
  shellHook = ''
    export GOPATH="$PWD/.go"
    export PATH="$GOPATH/bin:$PATH"
    echo "$(go version | cut -d' ' -f3-4) | gopls | delve"
  '';
}
