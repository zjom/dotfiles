# Leaf node: ripgrep.
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  nodes.ripgrep =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      ignores = config.settings.searchIgnores;
    in
    {
      imports = [
        (wlib.getInstallModule {
          name = "ripgrep";
          value = wlib.modules.default;
        })
      ];

      entry = lib.mkDefault "rg";

      wrappers.ripgrep =
        { config, ... }:
        {
          enable = true;
          package = pkgs.ripgrep;
          constructFiles.ripgreprc = {
            relPath = "share/ripgrep/ripgreprc";
            content = lib.concatLines (
              [
                "--hidden"
                "--smart-case"
                "--glob=!.DS_Store"
              ]
              ++ map (dir: "--glob=!${dir}/*") ignores
            );
          };
          env.RIPGREP_CONFIG_PATH = config.constructFiles.ripgreprc.path;
        };
    };
}
