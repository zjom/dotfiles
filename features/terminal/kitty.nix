# Leaf node: kitty, configured from kitty.conf.
{ leaf, ... }:
{
  # The upstream module passes --config, so kitty ignores ~/.config/kitty.
  # kitty.conf includes theme.conf by a relative path. kitty resolves that
  # path relative to the generated file. Thus, this setting points to the
  # copy of theme.conf in the store.
  nodes.kitty = leaf "kitty" {
    wrappers.kitty.extraConfig =
      builtins.replaceStrings [ "include theme.conf" ] [ "include ${./theme.conf}" ]
        (builtins.readFile ./kitty.conf);
  };
}
