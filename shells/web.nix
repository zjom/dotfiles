# Web toolchain + css_ls, html_ls, ts_ls + prettier
#   nix develop '~/dotfiles#web'
{ pkgs }:

let
  # nixpkgs ships a stale pnpmDeps hash for 6.0.2 (fetcher output drifted);
  # drop this once upstream corrects it.
  typescript-language-server = pkgs.typescript-language-server.overrideAttrs (prev: {
    pnpmDeps = prev.pnpmDeps.overrideAttrs {
      outputHash = "sha256-xR/EF60lVBsITKgH7wCM2wHM46PFQevD51KfCENSUH4=";
    };
  });
in
pkgs.mkShell {
  name = "web-dev";

  packages = with pkgs; [
    typescript-language-server
    nodejs_26
    pnpm
    bun
    prettier
    oxfmt
    oxlint
    vscode-langservers-extracted
  ];

  shellHook = ''
    echo "node $(node --version) | pnpm $(pnpm --version) | bun $(bun --version)"
  '';
}
