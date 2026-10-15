# Leaf node: niri, configured from ../../niri/config.kdl. The bindings that
# start other programs are in the desktop composite. The desktop composite adds
# these bindings with an `include`. The wrapper validates the configuration at
# build time.
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  nodes.niri =
    { lib, ... }:
    {
      imports = [
        (wlib.getInstallModule {
          name = "niri";
          value = wlib.wrapperModules.niri;
        })
      ];

      entry = lib.mkDefault "niri";

      # The upstream module sets NIRI_CONFIG, so niri ignores ~/.config/niri.
      wrappers.niri = {
        enable = true;
        "config.kdl".content = builtins.readFile ../../niri/config.kdl;
      };
    };
}
