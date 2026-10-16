# The desktop composite adds the bindings that start other programs. The
# wrapper validates niri.kdl at build time.
{ leaf, ... }:
{
  nodes.niri = leaf "niri" {
    wrappers.niri."config.kdl".content = builtins.readFile ./niri.kdl;
  };
}
