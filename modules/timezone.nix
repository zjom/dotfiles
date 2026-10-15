let
  timezone =
    { lib, ... }:
    {
      time.timeZone = lib.mkDefault "Australia/Melbourne";
    };
in
{
  nixos.base = timezone;
  darwin.base = timezone;
}
