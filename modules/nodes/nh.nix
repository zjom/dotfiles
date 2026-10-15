# Leaf node: nh. Use `nh os switch` and `nh darwin switch` in place of the
# *-rebuild commands. The flake that nh builds is a path on the machine, so each
# host sets `wrappers.nh.flake` (modules/system/nh.nix).
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  nodes.nh =
    { lib, ... }:
    {
      imports = [
        (wlib.getInstallModule {
          name = "nh";
          value = wlib.wrapperModules.nh;
        })
      ];

      entry = lib.mkDefault "nh";

      wrappers.nh = {
        enable = true;
        nom = false;
      };
    };
}
