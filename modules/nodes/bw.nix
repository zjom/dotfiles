# Leaf node: the Bitwarden password vault CLI. It has no configuration; its
# login and vault cache are state in its data directory.
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
