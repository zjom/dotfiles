# Leaf node: zoxide. zoxide has no configuration file. The database of zoxide is
# state in the XDG data directory.
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
