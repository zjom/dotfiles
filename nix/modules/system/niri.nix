# The niri desktop, system side: niri on its own, started from a greetd login
# on the console. Opt-in: imported by the hosts that want it, alongside
# modules/home/desktop for what runs inside the session. niri's own config is
# ../../../niri.
{ pkgs, ... }:

{
  programs.niri.enable = true;

  # A text greeter, so there is no second graphical stack just to log in.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --cmd niri-session";
      user = "greeter";
    };
  };

  # Unlock the GNOME keyring, which programs.niri turns on for its portals, with
  # the login password. (The swaylock PAM service is programs.niri's doing too.)
  security.pam.services.greetd.enableGnomeKeyring = true;

  fonts = {
    packages = with pkgs; [
      jetbrains-mono
      nerd-fonts.symbols-only
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrains Mono" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # Electron and Chromium apps run natively on Wayland instead of XWayland.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
