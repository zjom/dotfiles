# Home Manager configuration for the MacBook only. The shared modules are
# imported by the flake alongside this file.
{ config, pkgs, ... }:

{
  imports = [ ../../modules/home/gui.nix ];

  programs.aerospace = {
    enable = true;
    launchd.enable = true;
  };
  xdg.configFile."aerospace/aerospace.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.my.dotfilesRoot}/aerospace/aerospace.toml";

  home.packages = with pkgs; [
    duti
    pngpaste
  ];

  # Installed outside Nix; source them only where they exist.
  programs.fish.interactiveShellInit = ''
    test -f ~/.orbstack/shell/init2.fish; and source ~/.orbstack/shell/init2.fish 2>/dev/null
    test -f ~/Library/Google/google-cloud-sdk/path.fish.inc; and source ~/Library/Google/google-cloud-sdk/path.fish.inc
  '';
}
