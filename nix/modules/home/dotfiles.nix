# Configuration kept as a live symlink into the dotfiles checkout instead of a
# copy in the Nix store, so it can be edited without a rebuild.
{ config, ... }:

let
  inherit (config.my) dotfilesRoot;
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfilesRoot}/${path}";
in
{
  xdg.configFile = {
    "nvim".source = link "nvim";
    "ranger".source = link "ranger";
    "tmux".source = link "tmux";
  };
}
