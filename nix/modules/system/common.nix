# System level settings that NixOS and nix-darwin both understand. Anything
# that exists on only one of them lives in nixos.nix or darwin.nix.
{ lib, ... }:

{
  # Needed for claude-code, among others. Set here rather than in Home Manager
  # because the hosts use `home-manager.useGlobalPkgs`.
  nixpkgs.config.allowUnfree = true;

  time.timeZone = lib.mkDefault "Australia/Melbourne";
}
