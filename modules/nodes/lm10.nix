# Leaf node: lm10, the picker menu. lm10 only selects from the lines that it
# receives. The launcher composite supplies the scripts that give lm10 these
# lines.
{ inputs, leaf, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  nodes.lm10 = leaf "lm10" (
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (config.settings) colors;
      inherit (pkgs.stdenv.hostPlatform) system;
    in
    {
      wrappers.lm10 = {
        # lm10 has a package only for Linux. graph.nix skips the node on other
        # systems.
        package = inputs.lm10.packages.${system}.default or (throw "lm10 is not packaged for ${system}");
        # This file replaces ~/.config/lm10/lm10.ini.
        flags."--config" = "${pkgs.writeText "lm10.ini" (
          lib.generators.toINI { } {
            main = {
              font = "JetBrains Mono 15";
              border-width = 1;
              border-radius = 4;
            };
            colors = with colors; {
              background = "#${bg}ff";
              text = "#${fg}ff";
              prompt = "#${keyword}ff";
              placeholder = "#${comment}ff";
              input = "#${fg}ff";
              cursor = "#${fg}ff";
              match = "#${string}ff";
              selection = "#${line}ff";
              selection-text = "#${fg}ff";
              selection-match = "#${string}ff";
              counter = "#${comment}ff";
              border = "#${floatBorder}ff";
            };
          }
        )}";
      };
    }
  );
}
