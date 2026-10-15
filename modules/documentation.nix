# Man pages: the system's development pages and the Linux man-pages project.
{
  nixos.base.documentation.dev.enable = true;

  homeManager.base =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.man-pages ];
    };
}
