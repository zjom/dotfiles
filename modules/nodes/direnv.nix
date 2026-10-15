# Leaf node: direnv, with nix-direnv. nix-direnv makes `use flake` cache the
# shell, so direnv does not build the shell again each time you enter the
# directory. The allow list stays as state in the XDG data directory.
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
          # This directory replaces ~/.config/direnv.
          env.DIRENV_CONFIG = dirOf config.constructFiles.direnvrc.path;
        };
    };
}
