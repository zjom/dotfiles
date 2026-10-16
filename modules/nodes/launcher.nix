# Composite node: the lm10 pickers in ../../scripts/lm10. The pickers are for
# apps, sessions, Spotify, the clipboard history and the session menu. The
# scripts are the glue. Each script gives lm10 lines that start kitty, sesh,
# spotify_player and other programs by name. The scripts are installed next to
# lm10 itself. lm10-apps lists the scripts in its own directory.
{ config, ... }:
{
  nodes.launcher =
    { lib, pkgs, ... }:
    let
      scripts = pkgs.runCommandLocal "lm10-scripts" { } ''
        mkdir -p $out/bin
        cp ${../../scripts/lm10}/* $out/bin/
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
          # Linked into the bin/ directory of the lm10 wrapper. lm10-apps lists
          # the scripts in the directory of its own resolved path. This
          # directory is the directory of the scripts (decision D21).
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
          # cliphist, wl-copy and jq are plain tools, not configured programs.
          runtimePkgs = with pkgs; [
            cliphist
            jq
            wl-clipboard
          ];
        };
    };
}
