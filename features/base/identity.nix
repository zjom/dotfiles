# The identity of a system: the user that the system is built for, and the name
# of the configuration of the system in this flake. Each host in hosts/
# sets these values. System modules read the values as `config.my.*`. Home
# Manager modules read the values as `osConfig.my.*`.
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
