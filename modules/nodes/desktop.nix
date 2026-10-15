# Composite node: the niri desktop. This node contains only the glue between
# niri, the bar, the terminal and the pickers: the bindings and the buttons that
# start these programs.
{ config, ... }:
{
  nodes.desktop =
    { lib, pkgs, ... }:
    {
      imports = with config.nodes; [
        niri
        waybar
        mako
        swaylock
        kitty
        ranger
        launcher
      ];

      # The launcher starts lm10-apps. The desktop starts niri (decision D8).
      entry = lib.mkForce "niri";

      # niri merges the binds of an included file with its own binds.
      wrappers.niri."config.kdl".content = lib.mkAfter ''
        include "${pkgs.writeText "desktop-binds.kdl" ''
          binds {
              Mod+Q hotkey-overlay-title="Sesh picker" { spawn "lm10-sesh"; }
              Mod+Return hotkey-overlay-title="Terminal" { spawn "kitty" "--single-instance"; }
              Mod+E hotkey-overlay-title="Ranger" { spawn "kitty" "--single-instance" "--" "ranger"; }
              Mod+Space hotkey-overlay-title="Launcher" { spawn "lm10-apps"; }
              Mod+Shift+Escape hotkey-overlay-title="Session ctl" { spawn "lm10-session-ctl"; }
              Mod+F1 hotkey-overlay-title="Scripts" { spawn "lm10-apps" "scripts"; }
              Mod+F2 hotkey-overlay-title="Spotify" { spawn "lm10-spotify"; }
              Mod+Shift+V hotkey-overlay-title="Clipboard history" { spawn "lm10-clip"; }
          }
        ''}"
      '';

      wrappers.waybar.settings = {
        network.on-click = "kitty nmtui";
        bluetooth.on-click = "kitty bluetui";
        # A right-click opens the Spotify picker.
        mpris.on-click-right = "lm10-spotify";
      };
    };
}
