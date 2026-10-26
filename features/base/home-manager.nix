# Home Manager runs as a system module, so one `rebuild` activates the system
# and the user environment together.
{ config, inputs, ... }:

let
  inherit (config.flake.modules) homeManager;

  wiring =
    hmModule:
    { config, ... }:
    {
      imports = [ hmModule ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;

        backupFileExtension = "hm-bak";

        users.${config.my.username}.imports = [ homeManager.base ];
      };
    };
in
{
  flake.modules.nixos.base = wiring inputs.home-manager.nixosModules.home-manager;
  flake.modules.darwin.base = wiring inputs.home-manager.darwinModules.home-manager;

  flake.modules.homeManager.base = {
    xdg.enable = true;
  };
}
