# Screen locking: swaylock, and swayidle to start it.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  lock = "${lib.getExe pkgs.swaylock} -f";
in
{
  programs.swaylock = {
    enable = true;
    settings = with config.my.colors; {
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
        command = "${lib.getExe pkgs.niri} msg action power-off-monitors";
      }
    ];
    events = {
      before-sleep = lock;
      lock = lock;
    };
  };
}
