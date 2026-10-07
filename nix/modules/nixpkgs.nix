let
  unfree = {
    nixpkgs.config.allowUnfree = true;
  };
in
{
  nixos.base = unfree;
  darwin.base = unfree;
}
