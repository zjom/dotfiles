{ leaf, ... }:
{
  nodes.ripgrep =
    leaf
      {
        name = "ripgrep";
        entry = "rg";
      }
      (
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
          wrappers.ripgrep =
            { config, ... }:
            {
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
              env.RIPGREP_CONFIG_PATH = lib.mkForce config.constructFiles.ripgreprc.path;
            };
        }
      );
}
