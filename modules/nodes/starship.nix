# Leaf node: starship, with its default prompt.
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  nodes.starship =
    { lib, ... }:
    {
      imports = [
        (wlib.getInstallModule {
          name = "starship";
          value = wlib.wrapperModules.starship;
        })
      ];

      entry = lib.mkDefault "starship";

      # The upstream module sets STARSHIP_CONFIG to the generated file.
      wrappers.starship.enable = true;
    };
}
