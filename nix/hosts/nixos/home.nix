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

  vague = {
    bg = "141415";
    inactiveBg = "1c1c24";
    line = "252530";
    visual = "333738";
    fg = "cdcdcd";
    floatBorder = "878787";
    comment = "606079";
    keyword = "6e94b2";
    func = "c48282";
    string = "e8b589";
    plus = "7fa563";
    error = "d8647e";
    warning = "f3be7c";
  };
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
    bluetui
    brightnessctl
    imv
    kitty
    playerctl
    wl-clipboard
    # niri starts it on demand to run X11 programs.
    xwayland-satellite
  ];
  # xdg-open under niri falls back to its generic launcher, which does not
  # honour Terminal=true, so the terminal programs get entries that start
  # kitty themselves.
  xdg.desktopEntries = {
    nvim-kitty = {
      name = "Neovim (kitty)";
      exec = "kitty nvim %F";
      noDisplay = true;
    };
    ranger-kitty = {
      name = "Ranger (kitty)";
      exec = "kitty ranger %f";
      noDisplay = true;
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      let
        # mimeapps.list has no wildcards, so every type is listed.
        for = app: types: lib.genAttrs types (_: app);
      in
      for "firefox.desktop" [
        "text/html"
        "application/xhtml+xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "application/pdf"
      ]
      // for "nvim-kitty.desktop" [
        "text/plain"
        "text/markdown"
        "text/csv"
        "text/css"
        "text/javascript"
        "text/x-python"
        "text/x-lua"
        "text/x-nix"
        "text/rust"
        "text/x-go"
        "text/x-csrc"
        "text/x-chdr"
        "text/x-c++src"
        "text/x-c++hdr"
        "text/x-log"
        "text/x-makefile"
        "application/json"
        "application/toml"
        "application/yaml"
        "application/x-yaml"
        "application/xml"
        "application/x-shellscript"
        "application/javascript"
      ]
      // for "ranger-kitty.desktop" [ "inode/directory" ]
      // for "imv.desktop" [
        "image/png"
        "image/jpeg"
        "image/gif"
        "image/webp"
        "image/bmp"
        "image/tiff"
        "image/svg+xml"
      ]
      // {
        "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
      };
  };
  # Programs rewrite this file at runtime; replace it rather than refuse to
  # switch.
  xdg.configFile."mimeapps.list".force = true;

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
    settings = {
      main = {
        font = "JetBrains Mono:size=11";
        terminal = "kitty";
      };
      border = {
        width = 1;
        radius = 4;
      };
      colors = with vague; {
        background = "${bg}ff";
        text = "${fg}ff";
        prompt = "${keyword}ff";
        placeholder = "${comment}ff";
        input = "${fg}ff";
        match = "${string}ff";
        selection = "${line}ff";
        selection-text = "${fg}ff";
        selection-match = "${string}ff";
        counter = "${comment}ff";
        border = "${floatBorder}ff";
      };
    };
  };

  programs.swaylock = {
    enable = true;
    settings = with vague; {
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
    style = with vague; ''
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
}
