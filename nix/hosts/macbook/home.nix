# Home Manager configuration for the MacBook only. The shared modules are
# imported by the flake alongside this file.
{
  config,
  hostName,
  username,
  ...
}:

{
  home.username = username;
  home.homeDirectory = "/Users/${username}";

  # This machine keeps the nix branch of the dotfiles repository in a second
  # checkout, because ~/dotfiles is still the older stow based main branch.
  # Delete this line once there is one checkout at ~/dotfiles, as on WSL.
  my.dotfilesRoot = "${config.home.homeDirectory}/nix-dotfiles";

  my.shell.aliases.rebuild = "sudo darwin-rebuild switch --flake '${config.my.flakeRoot}#${hostName}'";

  programs.aerospace = {
    enable = true;
    launchd.enable = true;
  };
  xdg.configFile."aerospace/aerospace.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.my.dotfilesRoot}/aerospace/aerospace.toml";

}
