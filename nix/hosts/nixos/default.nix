# System level configuration for the bare metal NixOS machine.
{
  pkgs,
  hostName,
  username,
  ...
}:

{
  imports = [
    # Generated on the machine by `nixos-generate-config`; see the README.
    ./hardware-configuration.nix
    ../../modules/system/common.nix
    ../../modules/system/nixos.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = hostName;
  networking.networkmanager.enable = true;

  # Under WSL, NixOS-WSL declares the user; here nothing else does. Set a
  # password with `passwd` after the first boot.
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  hardware.graphics.enable = true;

  # The NixOS release whose defaults this system's stateful data was created
  # against. Set it to the release of the first install, the value
  # `nixos-generate-config` writes into its configuration.nix, and leave it.
  system.stateVersion = "26.11";
}
