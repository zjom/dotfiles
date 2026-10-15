# Locking: swayidle starts nodes.swaylock. swayidle is a service of the
# session, so it stays with Home Manager.
{
  flake.modules.homeManager.desktop =
    { lib, osConfig, ... }:
    let
      lock = "${lib.getExe osConfig.wrappers.swaylock.wrapper} -f";
    in
    {
      # Lock after 5 minutes idle, blank the screen a minute later, and always
      # lock before suspending.
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
