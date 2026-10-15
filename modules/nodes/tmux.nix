# Leaf node: tmux. Only tmux's own behaviour; the popups and pickers that
# start other programs live in composites.
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  nodes.tmux =
    { lib, pkgs, ... }:
    {
      imports = [
        (wlib.getInstallModule {
          name = "tmux";
          value = wlib.wrapperModules.tmux;
        })
      ];

      entry = lib.mkDefault "tmux";

      # The upstream module passes -f, so ~/.tmux.conf and ~/.config/tmux are
      # ignored.
      wrappers.tmux = {
        enable = true;
        sourceSensible = true;
        secureSocket = false;
        prefix = "C-Space";
        terminal = "screen-256color";
        mouse = true;
        escapeTime = 10;
        historyLimit = 2000;
        statusKeys = "vi";
        modeKeys = "vi";

        # Plugin settings, read when the plugins below load.
        configBefore = ''
          set -g @minimal-tmux-status "top"
          set -g @minimal-tmux-right false
          set -g @minimal-tmux-indicator-str '#S'
        '';

        plugins = with pkgs.tmuxPlugins; [
          yank
          minimal-tmux-status
        ];

        configAfter = ''
          set -a terminal-features "screen-256color:RGB"

          # Create new panes and windows in the same working directory.
          bind -N "Split pane vertically" v split-window -hc "#{pane_current_path}"
          bind '|' split-window -hc "#{pane_current_path}"
          bind -N "Split pane horizontally" '"' split-window -vc "#{pane_current_path}"
          bind -N "New window" c new-window -c "#{pane_current_path}"

          unbind M-o
          bind -N "Rotate pane" "#" rotate-window

          # Copy mode pane navigation, matching the C-hjkl bindings outside it.
          bind -T copy-mode-vi C-h select-pane -L
          bind -T copy-mode-vi C-j select-pane -D
          bind -T copy-mode-vi C-k select-pane -U
          bind -T copy-mode-vi C-l select-pane -R
          bind -T copy-mode-vi C-\\ select-pane -l
        '';
      };
    };
}
