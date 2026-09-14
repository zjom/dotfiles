# System level configuration for the MacBook.
{ pkgs, username, ... }:

{
  imports = [
    ../../modules/system/common.nix
    ../../modules/system/darwin.nix
  ];

  # macOS defaults, launchd agents, Homebrew and the rest of the nix-darwin
  # options belong here: they have no counterpart on the NixOS host.
  #   https://nix-darwin.github.io/nix-darwin/manual/

  # Required by the nix-darwin options that act on behalf of a single user.
  system.primaryUser = username;

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  # Homebrew is kept only for what Nix cannot install well: GUI apps and App
  # Store purchases. `cleanup = "zap"` uninstalls anything not listed here on
  # every rebuild -- including its application data -- so a stray
  # `brew install` never survives and no tool is ever installed twice.
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    brews = [
      "mas" # used by brew bundle to install masApps
    ];

    casks = [
      "alfred"
      "iina"
      "jordanbaird-ice"
      "orbstack"
      "shottr"
      "spotify"
    ];

    masApps = {
      "Dropover" = 1355679052;
      "Xcode" = 497799835;
    };
  };

  # Replaces the font casks. kitty asks for plain "JetBrains Mono" and draws
  # Nerd Font symbols itself; Meslo stays a Nerd Font as it was in Homebrew.
  fonts.packages = with pkgs; [
    fira-code
    hack-font
    jetbrains-mono
    nerd-fonts.meslo-lg
  ];

  # Touch ID for sudo, working inside tmux too. Replaces brew's pam-reattach.
  security.pam.services.sudo_local = {
    reattach = true;
    touchIdAuth = true;
  };

  # The nix-darwin state version, an integer unrelated to the NixOS one.
  system.stateVersion = 6;
}
