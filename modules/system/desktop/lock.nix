# Screen lock: swayidle starts nodes.swaylock. swayidle is a service of the
# session, so swayidle stays with Home Manager.
{
  flake.modules.homeManager.desktop =
    { lib, osConfig, ... }:
    let
      lock = "${lib.getExe osConfig.wrappers.swaylock.wrapper} -f";
    in
    {
      # Lock the screen after 5 minutes of idle time. Blank the screen 1
      # minute later. Always lock the screen before the machine suspends.
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
