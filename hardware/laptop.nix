# Hardware node (NixOS): a portable machine. This node configures the battery,
# the power profiles and Bluetooth.
{
  flake.modules.nixos.laptop =
    { lib, ... }:
    {
      hardware.bluetooth.enable = lib.mkDefault true;
      services.power-profiles-daemon.enable = lib.mkDefault true;
      services.upower.enable = lib.mkDefault true;
    };
}
