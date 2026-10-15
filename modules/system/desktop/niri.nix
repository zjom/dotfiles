# The niri desktop: niri on its own, started from a greetd login on the
# console. Importing nixos.desktop brings in nodes.desktop (niri, the bar,
# notifications, the locker, kitty and the pickers, all configured) and the
# Home Manager side: the services and session state of homeManager.desktop.
{ config, ... }:

let
  inherit (config.flake.modules) homeManager;
  inherit (config) nodes;
in
{
  flake.modules.nixos.desktop =
    { config, pkgs, ... }:
    {
      imports = [ nodes.desktop ];

      home-manager.sharedModules = [ homeManager.desktop ];

      # The wrapped niri, so niri-session runs the configured one.
      programs.niri = {
        enable = true;
        package = config.wrappers.niri.wrapper;
      };

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
}
