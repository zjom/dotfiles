# Leaf node: mako, the notification daemon. D-Bus activation starts mako. The
# wrapper changes the service file of mako so that the service file runs the
# wrapper.
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

      # The upstream module passes --config, so mako ignores ~/.config/mako.
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
