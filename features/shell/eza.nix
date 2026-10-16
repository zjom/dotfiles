{ leaf, ... }:
{
  nodes.eza = leaf "eza" (
    { pkgs, ... }:
    {
      wrappers.eza = {
        package = pkgs.eza;
        flags."--icons" = "always";
        env.EZA_CONFIG_DIR = "${pkgs.emptyDirectory}";
      };
    }
  );
}
