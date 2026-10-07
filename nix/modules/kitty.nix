# kitty, configured from ../../kitty, on hosts with a display of their own.
{
  homeManager.gui =
    { config, pkgs, ... }:
    {
      # Just the package: programs.kitty would generate its own kitty.conf in
      # ~/.config/kitty and collide with the directory symlink below.
      home.packages = [ pkgs.kitty ];
      xdg.configFile."kitty".source =
        config.lib.file.mkOutOfStoreSymlink "${config.my.dotfilesRoot}/kitty";
    };
}
