# Rust toolchain, with rust-analyzer.
#   nix develop '~/dotfiles#rust'
{ pkgs }:

pkgs.mkShell {
  name = "rust-dev";

  packages = with pkgs; [
    cargo
    rustc
    rustfmt
    clippy
    rust-analyzer

    just

    cargo-flamegraph
    cargo-release
    cargo-criterion
    cargo-expand
    cargo-hack
    cargo-machete
    cargo-nextest

    # Common build-time dependencies for crates that have native dependencies.
    pkg-config
  ];

  # rust-analyzer needs this value to find std, because nixpkgs supplies the
  # library sources separately from rustc.
  env.RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";

  shellHook = ''
    echo "rust $(rustc --version | cut -d' ' -f2) | cargo $(cargo --version | cut -d' ' -f2) | rust-analyzer"
  '';
}
