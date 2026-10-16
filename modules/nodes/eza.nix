# Leaf node: eza.
{ leaf, ... }:
{
  nodes.eza = leaf "eza" (
    { pkgs, ... }:
    {
      wrappers.eza = {
        package = pkgs.eza;
        flags."--icons" = "always";
        # An empty theme directory replaces ~/.config/eza.
        env.EZA_CONFIG_DIR = "${pkgs.emptyDirectory}";
      };
    }
  );
}
