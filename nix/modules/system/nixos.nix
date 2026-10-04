# System level settings shared by every NixOS host.
{ pkgs, username, ... }:

{
  users.users.${username}.shell = pkgs.fish;

  documentation.dev.enable = true;

  # macOS has no fontconfig; the fonts themselves are in common.nix.
  fonts.fontconfig.defaultFonts = {
    monospace = [ "JetBrains Mono" ];
    sansSerif = [ "Noto Sans" ];
    serif = [ "Noto Serif" ];
    emoji = [ "Noto Color Emoji" ];
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Lets unpatched dynamically linked binaries run, which language toolchains
  # installed outside Nix tend to need.
  programs.nix-ld.enable = true;
}
