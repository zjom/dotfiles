# The programs that run in the niri session: notifications, clipboard history,
# file associations, cursor, theme and the automount of removable drives.
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        bluetui
        brightnessctl
        imv
        # programs.niri registers nautilus only as a D-Bus service (for the file
        # chooser portal). Install it, for the desktop entry and the PATH.
        nautilus
        playerctl
        wl-clipboard
        # niri starts xwayland-satellite when necessary, to run X11 programs.
        xwayland-satellite
      ];

      # udiskie mounts removable drives through udisks2, on /run/media/<user>.
      services.udisks2.enable = true;

      # gvfs gives GIO its trash:// backend, for the Nautilus wastebasket.
      services.gvfs.enable = true;
    };

  flake.modules.homeManager.desktop =
    {
      config,
      lib,
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
          // for "org.gnome.Nautilus.desktop" [ "inode/directory" ]
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
        # Nautilus shows the XDG directories in its sidebar only when they are
        # in this bookmarks file. GNOME writes the file with xdg-user-dirs-gtk.
        gtk3.bookmarks = map (dir: "file://${config.home.homeDirectory}/${dir}") [
          "Documents"
          "Downloads"
          "Pictures"
          "GoogleDrive"
          "iCloud"
        ];
      };
      dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

      # The clipboard history for lm10-clipboard.
      services.cliphist.enable = true;

      services.polkit-gnome.enable = true;

      # Mount each USB drive when it is plugged in. udiskie sends a notification
      # to mako. The udiskie tray icon shows in waybar while a drive is
      # attached. Its menu unmounts and ejects the drives.
      services.udiskie = {
        enable = true;
        automount = true;
        notify = true;
        tray = "auto";
      };
    };
}
