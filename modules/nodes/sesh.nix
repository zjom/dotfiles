# Leaf node: sesh, with its default settings.
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  nodes.sesh =
    { lib, pkgs, ... }:
    {
      imports = [
        (wlib.getInstallModule {
          name = "sesh";
          value = wlib.modules.default;
        })
      ];

      entry = lib.mkDefault "sesh";

      wrappers.sesh =
        { config, ... }:
        {
          enable = true;
          package = pkgs.sesh;
          constructFiles.config = {
            relPath = "share/sesh/sesh.toml";
            content = "";
          };
          # In place of ~/.config/sesh/sesh.toml.
          flags."--config" = config.constructFiles.config.path;
        };
    };
}
