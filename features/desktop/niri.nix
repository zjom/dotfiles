# The desktop composite adds the bindings that start other programs. The
# wrapper validates niri.kdl at build time.
{ leaf, ... }:
{
  nodes.niri = leaf "niri" (
    { config, ... }:
    {
      wrappers.niri."config.kdl".content =
        builtins.replaceStrings [ "@bg@" ] [ "#${config.settings.colors.bg}" ]
          (builtins.readFile ./niri.kdl);
    }
  );
}
