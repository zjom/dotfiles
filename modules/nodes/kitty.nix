# Leaf node: kitty, configured from ../../kitty.
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  nodes.kitty =
    { lib, ... }:
    {
      imports = [
        (wlib.getInstallModule {
          name = "kitty";
          value = wlib.wrapperModules.kitty;
        })
      ];

      entry = lib.mkDefault "kitty";

      # The upstream module passes --config, so kitty ignores ~/.config/kitty.
      # kitty.conf includes theme.conf by a relative path. kitty resolves that
      # path relative to the generated file. Thus, this setting points to the
      # copy of theme.conf in the store.
      wrappers.kitty = {
        enable = true;
        extraConfig =
          builtins.replaceStrings [ "include theme.conf" ] [ "include ${../../kitty/theme.conf}" ]
            (builtins.readFile ../../kitty/kitty.conf);
      };
    };
}
