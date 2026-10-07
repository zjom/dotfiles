# Home Manager is wired in as a system module on every platform, so a single
# `rebuild` activates the system and the user environment together. The user
# gets homeManager.base; anything more is added through
# `home-manager.sharedModules` by the system modules that want it.
{ config, inputs, ... }:

let
  inherit (config) homeManager;

  wiring =
    hmModule:
    { config, ... }:
    {
      imports = [ hmModule ];

      home-manager = {
        # Reuse the system's nixpkgs (and its allowUnfree) instead of
        # instantiating a second one.
        useGlobalPkgs = true;
        useUserPackages = true;

        # Rename rather than fail when activation wants to write over a file
        # that is already there by hand.
        backupFileExtension = "hm-bak";

        users.${config.my.username}.imports = [ homeManager.base ];
      };
    };
in
{
  nixos.base = wiring inputs.home-manager.nixosModules.home-manager;
  darwin.base = wiring inputs.home-manager.darwinModules.home-manager;

  homeManager.base =
    { lib, ... }:
    {
      # Hosts may override this; they should not need to.
      home.stateVersion = lib.mkDefault "26.05";
    };
}
