# What runs inside the niri session: notifications, clipboard history, file
# associations, cursor and theme. The bar and locking have files of their own;
# the launcher is nodes.launcher.
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        bluetui
        brightnessctl
        imv
        playerctl
        wl-clipboard
        # niri starts it on demand to run X11 programs.
        xwayland-satellite
      ];
    };

  flake.modules.homeManager.desktop =
    {
      lib,
      osConfig,
      pkgs,
      ...
    }:
    {
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

      # nodes.mako, D-Bus activated through its own (patched) service file.
      services.mako = {
        enable = true;
        package = osConfig.wrappers.mako.wrapper;
      };

      # Clipboard history: stores every copy (wl-paste --watch), started with
      # graphical-session.target. scripts/lm10/lm10-clip picks from it.
      services.cliphist.enable = true;

      # Answers privilege prompts from GUI programs.
      services.polkit-gnome.enable = true;
    };
}
