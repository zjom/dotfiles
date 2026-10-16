# Leaf node: niri, configured from ../../niri/config.kdl. The bindings that
# start other programs are in the desktop composite. The desktop composite adds
# these bindings with an `include`. The wrapper validates the configuration at
# build time.
{ leaf, ... }:
{
  # The upstream module sets NIRI_CONFIG, so niri ignores ~/.config/niri.
  nodes.niri = leaf "niri" {
    wrappers.niri."config.kdl".content = builtins.readFile ../../niri/config.kdl;
  };
}
