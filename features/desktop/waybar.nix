{ leaf, ... }:
{
  nodes.waybar = leaf "waybar" (
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (config.settings) colors;
    in
    {
      wrappers.waybar = {
        settings = {
          layer = "top";
          position = "top";
          height = 26;
          modules-left = [ "niri/workspaces" ];
          modules-center = [ "clock" ];
          modules-right = [
            "mpris"
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
          };
          bluetooth = {
            format = "bt";
            format-off = "bt off";
            format-disabled = "bt off";
            format-connected = "bt {num_connections}";
            tooltip-format-connected = "{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}";
            tooltip-format-enumerate-connected-battery = "{device_alias} {device_battery_percentage}%";
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
          mpris = {
            format = "{status_icon} {dynamic}";
            format-paused = "{status_icon} {dynamic}";
            format-stopped = "";
            dynamic-order = [
              "artist"
              "title"
            ];
            dynamic-separator = " - ";
            dynamic-len = 45;
            status-icons = {
              playing = "▶";
              paused = "⏸";
            };
            tooltip-format = "{title}\n{artist}\n{album}\n{position} / {length}";
            interval = 1;
          };
          tray.spacing = 8;
        };

        # This value is a path because the module builds its default style file
        # from the wrong option.
        "style.css".path = pkgs.writeText "waybar-style.css" (
          with colors;
          ''
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
            #clock, #mpris, #tray, #network, #bluetooth, #pulseaudio, #battery {
              padding: 0 10px;
            }
            #network.disconnected, #bluetooth.off, #bluetooth.disabled, #pulseaudio.muted {
              color: #${comment};
            }
            #mpris.paused {
              color: #${comment};
            }
            #battery.charging {
              color: #${plus};
            }
            #battery.warning:not(.charging) {
              color: #${error};
            }
          ''
        );
      };
    }
  );

  # niri-session starts graphical-session.target, which starts the bar.
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
