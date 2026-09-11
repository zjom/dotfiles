# System level configuration for the WSL machine.
{ inputs, username, ... }:

{
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
    ../../modules/system/common.nix
    ../../modules/system/nixos.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = username;

  # The NixOS release whose defaults this system's stateful data was created
  # against. Leave it at the release of the first install; read the manual
  # before changing it.
  system.stateVersion = "26.05";
}
