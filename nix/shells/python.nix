# Python toolchain. uv owns virtualenvs and dependency resolution; Nix only
# provides the interpreter and the tools that sit outside a project's venv.
#   nix develop '~/dotfiles/nix#python'
{ pkgs }:

pkgs.mkShell {
  name = "python-dev";

  packages = with pkgs; [
    python313
    uv
    ruff # linter + formatter
    basedpyright
  ];

  # uv otherwise downloads its own interpreters, defeating the point of pinning
  # one here.
  env.UV_PYTHON_DOWNLOADS = "never";

  shellHook = ''
    echo "$(python3 --version) | uv $(uv --version | cut -d' ' -f2) | ruff | pyright"
  '';
}
