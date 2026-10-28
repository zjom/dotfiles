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

  shellHook = ''
    export GOPATH="$PWD/.go"
    export PATH="$GOPATH/bin:$PATH"
    echo "$(go version | cut -d' ' -f3-4) | gopls | delve"
  '';
}
