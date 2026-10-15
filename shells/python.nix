# Python toolchain. uv manages the virtualenvs and the dependency resolution.
# Nix supplies only the tools that are outside the venv of a project.
#   nix develop '~/dotfiles#python'
{ pkgs }:

pkgs.mkShell {
  name = "python-dev";

  packages = with pkgs; [
    uv
    ruff # linter and formatter
    ty
    basedpyright
  ];

  shellHook = ''
    echo "uv $(uv --version | cut -d' ' -f2) | ruff | ty | basedpyright"
  '';
}
