# Composite node: the macOS desktop. This node contains only the AeroSpace
# bindings that start kitty, with tmux in kitty.
{ config, ... }:
{
  nodes.mac-desktop = {
    imports = with config.nodes; [
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
}
