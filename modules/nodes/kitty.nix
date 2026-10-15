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

      # The upstream module passes --config, so ~/.config/kitty is ignored.
      # kitty.conf includes theme.conf by a relative path, which would resolve
      # against the generated file, so it is pointed at the store copy instead.
      wrappers.kitty = {
        enable = true;
        extraConfig =
          builtins.replaceStrings [ "include theme.conf" ] [ "include ${../../kitty/theme.conf}" ]
            (builtins.readFile ../../kitty/kitty.conf);
      };
    };
}
