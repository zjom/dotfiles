# Home Manager configuration for the MacBook only. The shared modules are
# imported by the flake alongside this file.
{
  config,
  pkgs,
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

  # Just the package: programs.kitty would generate its own kitty.conf in
  # ~/.config/kitty and collide with the directory symlink below.
  home.packages = with pkgs; [
    kitty

    # macOS-only CLIs, previously installed with Homebrew.
    duti
    pngpaste
  ];
  xdg.configFile."kitty".source =
    config.lib.file.mkOutOfStoreSymlink "${config.my.dotfilesRoot}/kitty";

}
