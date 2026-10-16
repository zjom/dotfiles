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
