# Composite node: the lm10 pickers in ../../scripts/lm10 -- apps, sessions,
# Spotify, the clipboard history, the session menu. The scripts are the glue:
# each one feeds lm10 lines that start kitty, sesh, spotify_player and so on
# by name. They are installed beside lm10 itself; lm10-apps lists the scripts
# next to it.
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
        sesh
        zoxide
        tmux
        fd
        spotify-player
      ];

      entry = "lm10-apps";

      wrappers.lm10 =
        { config, ... }:
        {
          # Linked into the lm10 wrapper's bin/. lm10-apps lists the scripts
          # beside its own resolved path, which is the scripts' directory.
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
