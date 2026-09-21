# Web toolchain + css_ls, html_ls, ts_ls + prettier
#   nix develop '~/dotfiles/nix#web'
{ pkgs }:

pkgs.mkShell {
  name = "web-dev";

  packages = with pkgs; [
    nodejs_26
    pnpm
    bun
    prettier
    oxfmt
    oxlint
    vscode-langservers-extracted
    typescript-language-server
  ];

  shellHook = ''
    echo "node $(node --version) | pnpm $(pnpm --version) | bun $(bun --version)"
  '';
}
