# Leaf node: bat. No settings of its own; the wrapper only keeps it off
# ~/.config/bat.
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  nodes.bat =
    { lib, pkgs, ... }:
    {
      imports = [
        (wlib.getInstallModule {
          name = "bat";
          value = wlib.modules.default;
        })
      ];

      entry = lib.mkDefault "bat";

      wrappers.bat =
        { config, ... }:
        {
          enable = true;
          package = pkgs.bat;
          constructFiles.config = {
            relPath = "share/bat/config";
            content = "";
          };
          env.BAT_CONFIG_PATH = config.constructFiles.config.path;
        };
    };
}
