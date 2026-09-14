# System level settings that NixOS and nix-darwin both understand. Anything
# that exists on only one of them lives in nixos.nix or darwin.nix.
{ lib, ... }:

{
  # Needed for claude-code, among others. Set here rather than in Home Manager
  # because the hosts use `home-manager.useGlobalPkgs`.
  nixpkgs.config.allowUnfree = true;

  time.timeZone = lib.mkDefault "Australia/Melbourne";

  # The login shell on every host. Enabling it system-wide installs fish, lists
  # it in /etc/shells and has it load the Nix environment; the user's shell is
  # set in nixos.nix and darwin.nix.
  programs.fish.enable = true;
}
