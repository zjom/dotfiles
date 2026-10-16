# The niri desktop. A host that imports nixos.desktop gets niri from a greetd
# login, nodes.desktop and homeManager.desktop.
{ config, ... }:
let
  inherit (config.flake.modules) homeManager;
  inherit (config) nodes;
in
{
  nodes.desktop =
    { lib, pkgs, ... }:
    {
      imports = with nodes; [
        niri
        waybar
        mako
        swaylock
        kitty
        launcher
      ];

      # The launcher starts lm10-apps. The desktop starts niri (decision D8).
      entry = lib.mkForce "niri";

      # niri merges the binds of an included file with its own binds.
      wrappers.niri."config.kdl".content = lib.mkAfter ''
        include "${pkgs.writeText "desktop-binds.kdl" ''
          binds {
              Mod+Q hotkey-overlay-title="Sesh picker" { spawn "lm10-sesh"; }
              Mod+Return hotkey-overlay-title="Terminal" { spawn "kitty" "--single-instance"; }
              Mod+E hotkey-overlay-title="File manager" { spawn-sh "xdg-open \"$HOME\""; }
              Mod+Space hotkey-overlay-title="Launcher" { spawn "lm10-apps"; }
              Mod+F1 hotkey-overlay-title="Scripts" { spawn "lm10-apps" "scripts"; }
              Mod+F2 hotkey-overlay-title="Spotify" { spawn "lm10-spotify"; }
              Mod+F3 hotkey-overlay-title="Clipboard history" { spawn "lm10-clipboard"; }
              Mod+F4 hotkey-overlay-title="Session ctl" { spawn "lm10-session-ctl"; }
          }
        ''}"
      '';

      wrappers.waybar.settings = {
        network.on-click = "kitty nmtui";
        bluetooth.on-click = "kitty bluetui";
        # A right-click opens the Spotify picker.
        mpris.on-click-right = "lm10-spotify";
      };
    };

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
