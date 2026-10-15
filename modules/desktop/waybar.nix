# The bar, nodes.waybar, started with graphical-session.target, which
# niri-session reaches. No settings here: the wrapper carries its own
# configuration, so Home Manager writes none.
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
