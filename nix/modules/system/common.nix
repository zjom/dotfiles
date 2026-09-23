# System level settings that NixOS and nix-darwin both understand. Anything
# that exists on only one of them lives in nixos.nix or darwin.nix.
{ lib, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (import ../../overlays/claude-code)
  ];

  time.timeZone = lib.mkDefault "Australia/Melbourne";

  # The login shell on every host. Enabling it system-wide installs fish, lists
  # it in /etc/shells and has it load the Nix environment; the user's shell is
  # set in nixos.nix and darwin.nix.
  programs.fish.enable = true;
}
