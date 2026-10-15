# Leaf node: the CLI of the Bitwarden password vault. The CLI has no
# configuration. The login and the vault cache are state in its data directory.
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  nodes.bw =
    { lib, pkgs, ... }:
    {
      imports = [
        (wlib.getInstallModule {
          name = "bw";
          value = wlib.modules.default;
        })
      ];

      entry = lib.mkDefault "bw";

      wrappers.bw = {
        enable = true;
        package = pkgs.bitwarden-cli;
      };
    };
}
