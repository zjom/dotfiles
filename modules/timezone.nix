let
  timezone =
    { lib, ... }:
    {
      time.timeZone = lib.mkDefault "Australia/Melbourne";
    };
in
{
  flake.modules.nixos.base = timezone;
  flake.modules.darwin.base = timezone;
}
