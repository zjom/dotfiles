{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {

      environment.systemPackages = with pkgs; [
        quickemu
        quickgui
      ];
    };
}
