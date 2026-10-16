# Composite node: list files. This node contains only the glue between fish and eza.
{ config, ... }:
{
  nodes.files = {
    imports = with config.nodes; [
      fish
      eza
    ];

    entry = "fish";

    wrappers.fish = {
      shellAliases = {
        ls = "eza";
        ll = "eza -l";
        la = "eza -a";
        lla = "eza -la";
        lt = "eza --tree";
        tree = "eza --tree";
      };
    };
  };
}
