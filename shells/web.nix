# Web toolchain, with css_ls, html_ls, ts_ls and prettier.
#   nix develop '~/dotfiles#web'
{ pkgs }:

let
  # nixpkgs has an old pnpmDeps hash for 6.0.2 (the fetcher output changed).
  # Remove this override when nixpkgs corrects the hash.
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
    prettier
    oxfmt
    oxlint
    vscode-langservers-extracted
    tailwindcss-language-server
  ];

  shellHook = ''
    echo "node $(node --version) | pnpm $(pnpm --version) | bun $(bun --version)"
  '';
}
