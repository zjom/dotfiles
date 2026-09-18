# Node toolchain + the TypeScript language server.
#   nix develop '~/dotfiles/nix#node'
{ pkgs }:

pkgs.mkShell {
  name = "node-dev";

  packages = with pkgs; [
    nodejs
    pnpm
    bun
    typescript
    prettier
    vscode-langservers-extracted
    typescript-language-server
  ];

  shellHook = ''
    echo "node $(node --version) | pnpm $(pnpm --version) | bun $(bun --version) | tsserver"
  '';
}
