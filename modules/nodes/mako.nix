# Leaf node: mako, the notification daemon. It is started by D-Bus
# activation; the wrapper patches its service file to run the wrapper.
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  nodes.mako =
    { lib, ... }:
    {
      imports = [
        (wlib.getInstallModule {
          name = "mako";
          value = wlib.wrapperModules.mako;
        })
      ];

      entry = lib.mkDefault "mako";

      # The upstream module passes --config, so ~/.config/mako is ignored.
      wrappers.mako = {
        enable = true;
        settings = {
          font = "JetBrains Mono 10";
          default-timeout = 5000;
          border-radius = 4;
        };
      };
    };
}
