# Who and what a system is: the user it is built for and the name of its
# configuration in this flake. Set by each host in modules/hosts, read by
# system modules as `config.my.*` and by Home Manager modules as
# `osConfig.my.*`.
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
  nixos.base = identity;
  darwin.base = identity;
}
