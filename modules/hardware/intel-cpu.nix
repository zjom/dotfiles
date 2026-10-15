# Hardware node (NixOS): an Intel CPU. The microcode itself follows this
# setting in the generated hardware configuration.
{
  flake.modules.nixos.intel-cpu =
    { lib, ... }:
    {
      hardware.enableRedistributableFirmware = lib.mkDefault true;
    };
}
