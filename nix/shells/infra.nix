# OpenTofu + tooling
#   nix develop '~/dotfiles/nix#infra'

{ pkgs }:

pkgs.mkShell {
  name = "infra-dev";

  packages = with pkgs; [
    opentofu
    opentofu-ls
  ];

  shellHook = ''
    echo "opentofu $(tofu --version)"
  '';
}
