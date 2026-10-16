{ leaf, ... }:
{
  # kitty resolves `include theme.conf` relative to the generated file. Thus,
  # the include points to the copy in the store.
  nodes.kitty = leaf "kitty" {
    wrappers.kitty.extraConfig =
      builtins.replaceStrings [ "include theme.conf" ] [ "include ${./theme.conf}" ]
        (builtins.readFile ./kitty.conf);
  };
}
