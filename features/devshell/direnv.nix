# direnv, with nix-direnv to cache the shells of `use flake`.
{ leaf, ... }:
{
  nodes.direnv = leaf "direnv" (
    { lib, pkgs, ... }:
    {
      wrappers.direnv =
        { config, ... }:
        {
          package = pkgs.direnv;
          constructFiles = {
            direnvrc = {
              relPath = "share/direnv/direnvrc";
              content = "source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc";
            };
            # Silent: direnv writes no log lines when you change the directory.
            "direnv.toml" = {
              relPath = "share/direnv/direnv.toml";
              content = ''
                [global]
                log_format = "-"
                log_filter = "^$"
              '';
            };
          };
          env.DIRENV_CONFIG = dirOf config.constructFiles.direnvrc.path;
        };
    }
  );
}
