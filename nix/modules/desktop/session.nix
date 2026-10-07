# What runs inside the niri session: launcher, notifications, file
# associations, cursor and theme. The bar and locking have files of their own.
{ config, ... }:

let
  inherit (config) colors;
in
{
  homeManager.desktop =
    { lib, pkgs, ... }:
    {
      home.packages = with pkgs; [
        bluetui
        brightnessctl
        imv
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
            font = "JetBrains Mono:size=15";
            terminal = "kitty";
          };
          border = {
            width = 1;
            radius = 4;
          };
          colors = with colors; {
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
    };
}
