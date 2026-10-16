# Leaf node: mako, the notification daemon. D-Bus activation starts mako. The
# wrapper changes the service file of mako so that the service file runs the
# wrapper.
{ leaf, ... }:
{
  # The upstream module passes --config, so mako ignores ~/.config/mako.
  nodes.mako = leaf "mako" {
    wrappers.mako.settings = {
      font = "JetBrains Mono 10";
      default-timeout = 5000;
      border-radius = 4;
    };
  };

  # D-Bus activates mako through its own (changed) service file.
  flake.modules.homeManager.desktop =
    { osConfig, ... }:
    {
      services.mako = {
        enable = true;
        package = osConfig.wrappers.mako.wrapper;
      };
    };
}
