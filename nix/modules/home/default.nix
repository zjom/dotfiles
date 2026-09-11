# Home Manager configuration shared by every host. Anything that only applies
# to one machine belongs in hosts/<name>/home.nix instead.
{ lib, ... }:

{
  imports = [
    ./options.nix
    ./dotfiles.nix
    ./git.nix
    ./packages.nix
    ./shell.nix
    ./tools.nix
  ];

  # Hosts may override this; they should not need to.
  home.stateVersion = lib.mkDefault "26.05";
}
