{ leaf, ... }:
{
  nodes.eza = leaf "eza" (
    { pkgs, lib, ... }:
    {
      wrappers.eza = {
        package = pkgs.eza;
        flags."--icons" = "always";
        env.EZA_CONFIG_DIR = lib.mkForce "${pkgs.emptyDirectory}";
      };
    }
  );
}
