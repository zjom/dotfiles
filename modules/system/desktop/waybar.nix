# The bar, nodes.waybar. The bar starts with graphical-session.target, and
# niri-session starts that target. This file has no settings. The wrapper
# contains the configuration, so Home Manager writes no configuration file.
{
  flake.modules.homeManager.desktop =
    { osConfig, ... }:
    {
      programs.waybar = {
        enable = true;
        package = osConfig.wrappers.waybar.wrapper;
        systemd.enable = true;
      };
    };
}
