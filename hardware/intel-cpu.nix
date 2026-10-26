# Hardware module (NixOS): an Intel CPU. The microcode update in the generated
# hardware configuration uses this setting.
{
  flake.modules.nixos.intel-cpu =
    { lib, ... }:
    {
      hardware.enableRedistributableFirmware = lib.mkDefault true;
    };
}
