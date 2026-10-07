# The niri desktop: niri on its own, started from a greetd login on the
# console. Importing nixos.desktop brings in the Home Manager side too --
# homeManager.desktop for what runs inside the session, homeManager.gui for
# kitty. niri's own config is ../../../niri.
{ config, ... }:

let
  inherit (config) homeManager;
in
{
  nixos.desktop =
    { pkgs, ... }:
    {
      home-manager.sharedModules = [
        homeManager.desktop
        homeManager.gui
      ];

      programs.niri.enable = true;

      # A text greeter, so there is no second graphical stack just to log in.
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --cmd niri-session";
          user = "greeter";
        };
      };

      # Unlock the GNOME keyring, which programs.niri turns on for its portals,
      # with the login password. (The swaylock PAM service is programs.niri's
      # doing too.)
      security.pam.services.greetd.enableGnomeKeyring = true;

      # Electron and Chromium apps run natively on Wayland instead of XWayland.
      environment.sessionVariables.NIXOS_OZONE_WL = "1";
    };

  homeManager.desktop =
    { config, ... }:
    {
      xdg.configFile."niri".source =
        config.lib.file.mkOutOfStoreSymlink "${config.my.dotfilesRoot}/niri";
    };
}
