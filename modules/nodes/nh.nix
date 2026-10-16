# Leaf node: nh. Use `nh os switch` and `nh darwin switch` in place of the
# *-rebuild commands. The flake that nh builds is a path on the machine, so each
# host sets `wrappers.nh.flake` (modules/system/nh.nix).
{ leaf, ... }:
{
  nodes.nh = leaf "nh" {
    wrappers.nh.nom = false;
  };
}
