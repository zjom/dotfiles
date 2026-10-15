# Leaf node: ranger, configured from ../../ranger. History and bookmarks stay
# state in the XDG data directory.
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  nodes.ranger =
    { lib, pkgs, ... }:
    {
      imports = [
        (wlib.getInstallModule {
          name = "ranger";
          value = wlib.modules.default;
        })
      ];

      entry = lib.mkDefault "ranger";

      wrappers.ranger = {
        enable = true;
        package = pkgs.ranger;
        # In place of ~/.config/ranger.
        flags."--confdir" = "${../../ranger}";
      };
    };
}
