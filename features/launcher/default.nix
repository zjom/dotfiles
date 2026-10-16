# The lm10 pickers in ./scripts. lm10-apps lists the scripts in its own
# directory, so the scripts are linked next to lm10.
{ config, ... }:
{
  nodes.launcher =
    { lib, pkgs, ... }:
    let
      scripts = pkgs.runCommandLocal "lm10-scripts" { } ''
        mkdir -p $out/bin
        cp ${./scripts}/* $out/bin/
        chmod +x $out/bin/*
      '';
    in
    {
      imports = with config.nodes; [
        lm10
        fish
        kitty
        tmux
        fd
        spotify-player
      ];

      packages = [
        pkgs.sesh
        pkgs.zoxide
      ];

      entry = "lm10-apps";

      wrappers.lm10 =
        { config, ... }:
        {
          buildCommand.launcherScripts = {
            after = [
              "makeWrapper"
              "symlinkScript"
            ];
            data = ''
              for script in ${scripts}/bin/*; do
                ln -s "$script" ${placeholder config.outputName}/bin/
              done
            '';
          };
          runtimePkgs = with pkgs; [
            cliphist
            jq
            wl-clipboard
          ];
        };
    };
}
