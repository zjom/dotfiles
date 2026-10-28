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
        package = inputs.lm10.packages.${system}.default or (throw "lm10 is not packaged for ${system}");
        flags."--config" = "${pkgs.writeText "lm10.ini" (
          lib.generators.toINI { } {
            main = {
              font = "JetBrains Mono 15";
              border-width = 2;
              border-radius = 12;
              lines = 8;
              padding = 14;
              row-padding = 8;
              selection-radius = 8;
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
