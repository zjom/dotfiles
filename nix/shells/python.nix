# Python toolchain. uv owns virtualenvs and dependency resolution;
# Nix only provides the tools that sit outside a project's venv.
#   nix develop '~/dotfiles/nix#python'
{ pkgs }:

pkgs.mkShell {
  name = "python-dev";

  packages = with pkgs; [
    uv
    ruff # linter + formatter
    ty
    basedpyright
  ];

  shellHook = ''
    echo "uv $(uv --version | cut -d' ' -f2) | ruff | ty | basedpyright"
  '';
}
