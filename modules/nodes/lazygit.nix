# Leaf node: lazygit, with its default settings. LG_CONFIG_FILE moves only the
# configuration. The state.yml file of lazygit stays in ~/.config/lazygit.
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  nodes.lazygit =
    { lib, pkgs, ... }:
    {
      imports = [
        (wlib.getInstallModule {
          name = "lazygit";
          value = wlib.modules.default;
        })
      ];

      entry = lib.mkDefault "lazygit";

      wrappers.lazygit =
        { config, ... }:
        {
          enable = true;
          package = pkgs.lazygit;
          constructFiles.config = {
            relPath = "share/lazygit/config.yml";
            content = "{}";
          };
          env.LG_CONFIG_FILE = config.constructFiles.config.path;
        };
    };
}
