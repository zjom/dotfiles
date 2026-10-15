# ranger, configured from ../../ranger.
{
  flake.modules.homeManager.base =
    { config, pkgs, ... }:
    {
      home.packages = [ pkgs.ranger ];
      xdg.configFile."ranger".source =
        config.lib.file.mkOutOfStoreSymlink "${config.my.dotfilesRoot}/ranger";
    };
}
