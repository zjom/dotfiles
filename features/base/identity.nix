# The user and the configuration name of a host. Each host sets these values.
let
  identity =
    { lib, ... }:
    {
      options.my = {
        username = lib.mkOption {
          type = lib.types.str;
          description = "The one user this system is configured for.";
        };

        hostName = lib.mkOption {
          type = lib.types.str;
          description = ''
            Name of this host's configuration in the flake. Not necessarily the
            machine's hostname: under WSL that is "nixos".
          '';
        };
      };
    };
in
{
  flake.modules.nixos.base = identity;
  flake.modules.darwin.base = identity;
}
