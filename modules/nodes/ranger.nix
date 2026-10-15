# Leaf node: ranger, configured from ../../ranger. The history and the bookmarks
# stay as state in the XDG data directory.
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
        # This directory replaces ~/.config/ranger.
        flags."--confdir" = "${../../ranger}";
      };
    };
}
