# Leaf node: swaylock, the screen locker.
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  nodes.swaylock =
    { config, lib, ... }:
    let
      inherit (config.settings) colors;
    in
    {
      imports = [
        (wlib.getInstallModule {
          name = "swaylock";
          value = wlib.wrapperModules.swaylock;
        })
      ];

      entry = lib.mkDefault "swaylock";

      # The upstream module passes --config, so ~/.config/swaylock is ignored.
      wrappers.swaylock = {
        enable = true;
        settings = with colors; {
          color = bg;
          show-failed-attempts = true;
          font = "JetBrains Mono";
          indicator-radius = 80;
          indicator-thickness = 6;

          inside-color = bg;
          inside-clear-color = bg;
          inside-caps-lock-color = bg;
          inside-ver-color = bg;
          inside-wrong-color = bg;

          ring-color = line;
          ring-clear-color = warning;
          ring-caps-lock-color = warning;
          ring-ver-color = keyword;
          ring-wrong-color = error;

          key-hl-color = keyword;
          caps-lock-key-hl-color = string;
          bs-hl-color = func;
          caps-lock-bs-hl-color = func;

          line-uses-inside = true;
          separator-color = "00000000";

          text-color = fg;
          text-clear-color = warning;
          text-caps-lock-color = warning;
          text-ver-color = keyword;
          text-wrong-color = error;
        };
      };
    };
}
