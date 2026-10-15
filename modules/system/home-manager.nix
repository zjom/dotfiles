# Home Manager is a system module on each platform. Thus, one `rebuild`
# activates the system and the user environment together. The user gets
# homeManager.base. System modules that need more Home Manager configuration add
# it through `home-manager.sharedModules`.
{ config, inputs, ... }:

let
  inherit (config.flake.modules) homeManager;

  wiring =
    hmModule:
    { config, ... }:
    {
      imports = [ hmModule ];

      home-manager = {
        # Use the nixpkgs of the system (and its allowUnfree value). Do not
        # create a second nixpkgs instance.
        useGlobalPkgs = true;
        useUserPackages = true;

        # If activation must write a file that already exists, rename
        # the existing file. Do not fail.
        backupFileExtension = "hm-bak";

        users.${config.my.username}.imports = [ homeManager.base ];
      };
    };
in
{
  flake.modules.nixos.base = wiring inputs.home-manager.nixosModules.home-manager;
  flake.modules.darwin.base = wiring inputs.home-manager.darwinModules.home-manager;

  flake.modules.homeManager.base =
    { lib, ... }:
    {
      # Hosts can override this value. Hosts do not need to override it.
      home.stateVersion = lib.mkDefault "26.05";

      # Defines the XDG_* variables in the session environment.
      xdg.enable = true;
    };
}
