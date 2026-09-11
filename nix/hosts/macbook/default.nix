# System level configuration for the MacBook.
{ username, ... }:

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

  # The nix-darwin state version, an integer unrelated to the NixOS one.
  system.stateVersion = 6;
}
