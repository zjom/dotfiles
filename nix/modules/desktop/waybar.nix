# The bar.
{ config, ... }:

let
  inherit (config) colors;
in
{
  homeManager.desktop =
    {
      programs.waybar = {
        enable = true;
        # Started with graphical-session.target, which niri-session reaches.
        systemd.enable = true;
        settings.main = {
          layer = "top";
          position = "top";
          height = 26;
          modules-left = [ "niri/workspaces" ];
          modules-center = [ "clock" ];
          modules-right = [
            "tray"
            "network"
            "bluetooth"
            "pulseaudio"
            "battery"
          ];
          clock.format = "{:%a %d %b  %H:%M}";
          network = {
            format-wifi = "{essid}";
            format-ethernet = "wired";
            format-disconnected = "offline";
            on-click = "kitty nmtui";
          };
          bluetooth = {
            format = "bt";
            format-off = "bt off";
            format-disabled = "bt off";
            format-connected = "bt {device_alias}";
            format-connected-battery = "bt {device_alias} {device_battery_percentage}%";
            tooltip-format-connected = "{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}";
            on-click = "kitty bluetui";
          };
          pulseaudio = {
            format = "vol {volume}%";
            format-muted = "muted";
            on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          };
          battery = {
            format = "bat {capacity}%";
            format-charging = "chg {capacity}%";
            states.warning = 20;
          };
          tray.spacing = 8;
        };
        style = with colors; ''
          * {
            font-family: "JetBrains Mono", "Symbols Nerd Font";
            font-size: 12px;
            min-height: 0;
          }
          window#waybar {
            background: #${bg};
            color: #${fg};
            border-bottom: 1px solid #${line};
          }
          #workspaces button {
            padding: 0 6px;
            color: #${comment};
            border-radius: 0;
          }
          #workspaces button:hover {
            background: #${line};
            box-shadow: none;
            text-shadow: none;
          }
          #workspaces button.active {
            color: #${fg};
            box-shadow: inset 0 -2px #${keyword};
          }
          #workspaces button.urgent {
            color: #${error};
          }
          tooltip {
            background: #${inactiveBg};
            border: 1px solid #${floatBorder};
          }
          tooltip label {
            color: #${fg};
          }
          #clock, #tray, #network, #bluetooth, #pulseaudio, #battery {
            padding: 0 10px;
          }
          #network.disconnected, #bluetooth.off, #bluetooth.disabled, #pulseaudio.muted {
            color: #${comment};
          }
          #battery.charging {
            color: #${plus};
          }
          #battery.warning:not(.charging) {
            color: #${error};
          }
        '';
      };
    };
}
