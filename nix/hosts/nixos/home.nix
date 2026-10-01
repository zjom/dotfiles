# Home Manager configuration for the bare metal NixOS machine only. The shared
# modules are imported by the flake alongside this file.
{
  config,
  lib,
  pkgs,
  hostName,
  username,
  ...
}:

let
  link = path: config.lib.file.mkOutOfStoreSymlink "${config.my.dotfilesRoot}/${path}";
  lock = "${lib.getExe pkgs.swaylock} -f";
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";

  my.shell.aliases.rebuild = "sudo nixos-rebuild switch --flake '${config.my.flakeRoot}#${hostName}'";

  xdg.configFile = {
    "niri".source = link "niri";
    "kitty".source = link "kitty";
  };

  home.packages = with pkgs; [
    brightnessctl
    kitty
    playerctl
    wl-clipboard
    # niri starts it on demand to run X11 programs.
    xwayland-satellite
  ];
  home.pointerCursor = {
    enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
    gtk.enable = true;
  };

  gtk = {
    enable = true;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
  };
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  programs.fuzzel = {
    enable = true;
    settings.main = {
      font = "JetBrains Mono:size=11";
      terminal = "kitty";
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      color = "0e1419";
      show-failed-attempts = true;
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

  services.mako = {
    enable = true;
    settings = {
      font = "JetBrains Mono 10";
      default-timeout = 5000;
      border-radius = 4;
    };
  };

  # Answers privilege prompts from GUI programs.
  services.polkit-gnome.enable = true;

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
    style = ''
      * {
        font-family: "JetBrains Mono", "Symbols Nerd Font";
        font-size: 12px;
        min-height: 0;
      }
      window#waybar {
        background: #0e1419;
        color: #f8f8f2;
      }
      #workspaces button {
        padding: 0 6px;
        color: #6272a4;
        border-radius: 0;
      }
      #workspaces button.active {
        color: #f8f8f2;
        box-shadow: inset 0 -2px #e11299;
      }
      #clock, #tray, #network, #pulseaudio, #battery {
        padding: 0 10px;
      }
      #battery.warning:not(.charging) {
        color: #ff5555;
      }
    '';
  };
}
