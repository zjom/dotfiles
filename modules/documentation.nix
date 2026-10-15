# Man pages: the system's development pages and the Linux man-pages project.
{
  flake.modules.nixos.base.documentation.dev.enable = true;

  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.man-pages ];
    };
}
