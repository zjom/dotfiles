# Leaf node: eza.
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  nodes.eza =
    { lib, pkgs, ... }:
    {
      imports = [
        (wlib.getInstallModule {
          name = "eza";
          value = wlib.modules.default;
        })
      ];

      entry = lib.mkDefault "eza";

      wrappers.eza = {
        enable = true;
        package = pkgs.eza;
        flags."--icons" = "always";
        # An empty theme directory in place of ~/.config/eza.
        env.EZA_CONFIG_DIR = "${pkgs.emptyDirectory}";
      };
    };
}
