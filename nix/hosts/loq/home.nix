# Home Manager configuration for the bare metal NixOS machine only. The shared
# modules are imported by the flake alongside this file.
{ pkgs, ... }:

{
  imports = [
    ../../modules/home/desktop
    ../../modules/home/gui.nix
  ];

  home.packages = with pkgs; [
    anki
    aseprite
  ];
}
