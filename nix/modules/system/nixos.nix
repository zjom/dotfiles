# System level settings shared by every NixOS host.
{ pkgs, username, ... }:

{
  users.users.${username}.shell = pkgs.fish;

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
