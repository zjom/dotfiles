# The niri desktop: niri alone, started from a greetd login on the console. If a
# host imports nixos.desktop, the host also gets nodes.desktop and the Home
# Manager configuration. nodes.desktop contains niri, the bar, the
# notifications, the screen locker, kitty and the pickers, all configured. The
# Home Manager configuration is homeManager.desktop, with the services and the
# session state.
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

      # The wrapped niri, so niri-session runs the configured niri.
      programs.niri = {
        enable = true;
        package = config.wrappers.niri.wrapper;
      };

      # A text greeter, so the login needs no second graphical stack.
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --cmd niri-session";
          user = "greeter";
        };
      };

      # Unlock the GNOME keyring with the login password. programs.niri enables
      # the GNOME keyring for its portals. programs.niri also creates the PAM
      # service for swaylock.
      security.pam.services.greetd.enableGnomeKeyring = true;

      # Electron apps and Chromium apps run natively on Wayland, not on
      # XWayland.
      environment.sessionVariables.NIXOS_OZONE_WL = "1";
    };
}
