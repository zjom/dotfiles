# System level settings that NixOS and nix-darwin both understand. Anything
# that exists on only one of them lives in nixos.nix or darwin.nix.
{ lib, pkgs, ... }:

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

  # The same fonts on every host. JetBrains Mono is the monospace font
  # everywhere (kitty, waybar, fuzzel, swaylock); kitty draws Nerd Font symbols
  # itself, other programs fall back to Symbols Nerd Font. NixOS also makes
  # these the fontconfig defaults (nixos.nix).
  fonts.packages = with pkgs; [
    fira-code
    hack-font
    jetbrains-mono
    nerd-fonts.meslo-lg
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];
}
