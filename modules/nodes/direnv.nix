# Leaf node: direnv, with nix-direnv so `use flake` caches the shell instead of
# rebuilding it on every entry. The allow list stays state in the XDG data
# directory.
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  nodes.direnv =
    { lib, pkgs, ... }:
    {
      imports = [
        (wlib.getInstallModule {
          name = "direnv";
          value = wlib.modules.default;
        })
      ];

      entry = lib.mkDefault "direnv";

      wrappers.direnv =
        { config, ... }:
        {
          enable = true;
          package = pkgs.direnv;
          constructFiles = {
            direnvrc = {
              relPath = "share/direnv/direnvrc";
              content = "source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc";
            };
            # Silent: no log lines on every cd.
            "direnv.toml" = {
              relPath = "share/direnv/direnv.toml";
              content = ''
                [global]
                log_format = "-"
                log_filter = "^$"
              '';
            };
          };
          # In place of ~/.config/direnv.
          env.DIRENV_CONFIG = dirOf config.constructFiles.direnvrc.path;
        };
    };
}
