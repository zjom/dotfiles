# Hardware module (NixOS): CUPS with mDNS discovery for driverless network
# printers.
{
  flake.modules.nixos.printing =
    { lib, ... }:
    {
      services.printing.enable = lib.mkDefault true;
      services.avahi = {
        enable = lib.mkDefault true;
        nssmdns4 = lib.mkDefault true;
        openFirewall = lib.mkDefault true;
      };
    };
}
