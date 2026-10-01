# get-ignore: CLI to fetch, compose and maintain gitignore files.
# Built from its own flake (the `get-ignore` input) rather than nixpkgs.
{ inputs, pkgs, ... }:

{
  home.packages = [
    inputs.get-ignore.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
