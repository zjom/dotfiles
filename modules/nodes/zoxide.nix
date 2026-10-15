# Leaf node: zoxide. It has no configuration file; its database is state in
# the XDG data directory.
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  nodes.zoxide =
    { lib, pkgs, ... }:
    {
      imports = [
        (wlib.getInstallModule {
          name = "zoxide";
          value = wlib.modules.default;
        })
      ];

      entry = lib.mkDefault "zoxide";

      wrappers.zoxide = {
        enable = true;
        package = pkgs.zoxide;
      };
    };
}
