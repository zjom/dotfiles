# Leaf node: bat. bat has no settings of its own. The wrapper only makes bat
# ignore ~/.config/bat.
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
