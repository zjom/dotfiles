# snot: reader, formatter, checker and language server for Simple Note Format.
# Built from its own flake (the `snot` input) rather than nixpkgs.
{ inputs, pkgs, ... }:

{
  home.packages = [
    inputs.snot.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
