# swayidle locks the screen with the swaylock node.
{
  flake.modules.homeManager.desktop =
    { lib, osConfig, ... }:
    let
      lock = "${lib.getExe osConfig.wrappers.swaylock.wrapper} -f";
    in
    {
      services.swayidle = {
        enable = true;
        timeouts = [
          {
            timeout = 300;
            command = lock;
          }
          {
            timeout = 360;
            command = "${lib.getExe osConfig.programs.niri.package} msg action power-off-monitors";
          }
        ];
        events = {
          before-sleep = lock;
          lock = lock;
        };
      };
    };
}
