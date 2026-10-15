# Man pages: the system's development pages and the Linux man-pages project.
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      documentation.dev.enable = true;
      environment.systemPackages = [ pkgs.man-pages ];
    };

  flake.modules.darwin.base =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.man-pages ];
    };
}
