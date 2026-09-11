# Rust toolchain + rust-analyzer.
#   nix develop ~/dotfiles/nix#rust
{ pkgs }:

pkgs.mkShell {
  name = "rust-dev";

  packages = with pkgs; [
    cargo
    rustc
    rustfmt
    clippy
    rust-analyzer

    # Common build-time deps for crates with native dependencies.
    pkg-config
  ];

  # rust-analyzer needs this to resolve std, since nixpkgs ships the
  # library sources separately from rustc.
  env.RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";

  shellHook = ''
    echo "rust $(rustc --version | cut -d' ' -f2) | cargo $(cargo --version | cut -d' ' -f2) | rust-analyzer"
  '';
}
