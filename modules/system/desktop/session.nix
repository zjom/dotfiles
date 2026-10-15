# The programs that run in the niri session: notifications, clipboard history,
# file associations, cursor and theme. The bar and the screen lock have separate
# files. The launcher is nodes.launcher.
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
        # niri starts xwayland-satellite when necessary, to run X11 programs.
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
      # Under niri, xdg-open uses its generic launcher as a fallback. The
      # generic launcher ignores Terminal=true. Thus, each terminal program gets
      # an entry that starts kitty itself.
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
            # mimeapps.list has no wildcards, so this list contains each type.
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
      # Programs change this file at run time. Replace the file, so that the
      # switch does not fail.
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

      # nodes.mako. D-Bus activates mako through its own (changed) service file.
      services.mako = {
        enable = true;
        package = osConfig.wrappers.mako.wrapper;
      };

      # Clipboard history: cliphist stores each copy (wl-paste --watch). The
      # service starts with graphical-session.target. scripts/lm10/lm10-clipboard
      # selects entries from this history.
      services.cliphist.enable = true;

      # Shows the privilege prompts of GUI programs.
      services.polkit-gnome.enable = true;
    };
}
