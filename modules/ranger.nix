# ranger, configured from ../../ranger.
{
  homeManager.base =
    { config, pkgs, ... }:
    {
      home.packages = [ pkgs.ranger ];
      xdg.configFile."ranger".source =
        config.lib.file.mkOutOfStoreSymlink "${config.my.dotfilesRoot}/ranger";
    };
}
