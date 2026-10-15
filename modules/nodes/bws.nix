# Leaf node: the Bitwarden Secrets Manager CLI. Its access token is never
# part of the configuration; the bitwarden composite reads it from the
# keyring for each call.
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
