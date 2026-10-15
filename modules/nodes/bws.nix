# Leaf node: the Bitwarden Secrets Manager CLI. The access token of the CLI is
# never part of the configuration. The bitwarden composite reads the access
# token from the keyring for each call.
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  nodes.bws =
    { lib, pkgs, ... }:
    {
      imports = [
        (wlib.getInstallModule {
          name = "bws";
          value = wlib.modules.default;
        })
      ];

      entry = lib.mkDefault "bws";

      wrappers.bws = {
        enable = true;
        package = pkgs.bws;
      };
    };
}
