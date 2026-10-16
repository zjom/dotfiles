# The macOS desktop: AeroSpace, with the bindings that start kitty and tmux.
{ config, ... }:
let
  inherit (config) nodes;
in
{
  nodes.mac-desktop = {
    imports = with nodes; [
      aerospace
      kitty
      tmux
    ];

    entry = "aerospace";

    wrappers.aerospace.settings.mode.main.binding = {
      alt-q = "exec-and-forget kitty -d $HOME --single-instance -- sh -c 'tmux new -A -s default; while tmux has-session 2>/dev/null; do tmux attach; done'";
      alt-space = "exec-and-forget kitten quick-access-terminal -o margin_top=12 -o margin_right=12 -o margin_left=12 -o background_opacity=1";
    };
  };

  flake.modules.darwin.mac-desktop = {
    imports = [ nodes.mac-desktop ];

    # The AeroSpace server starts at login. The wrapper contains the
    # configuration, so Home Manager writes no configuration file.
    home-manager.sharedModules = [
      (
        { osConfig, ... }:
        {
          programs.aerospace = {
            enable = true;
            package = osConfig.wrappers.aerospace.wrapper;
            launchd.enable = true;
          };
        }
      )
    ];
  };
}
