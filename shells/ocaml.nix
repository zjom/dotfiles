# OCaml toolchain, with ocaml-lsp.
#   nix develop '~/dotfiles#ocaml'
{ pkgs }:

pkgs.mkShell {
  name = "ocaml-dev";

  packages = with pkgs; [
    ocaml
    dune_3
    opam
    ocamlPackages.ocaml-lsp
    ocamlPackages.ocamlformat
    ocamlPackages.utop
  ];

  shellHook = ''
    echo "ocaml $(ocaml -version | cut -d' ' -f4) | dune $(dune --version) | ocamllsp"
  '';
}
