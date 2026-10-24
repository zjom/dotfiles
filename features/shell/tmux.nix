{ leaf, ... }:
{
  nodes.tmux = leaf "tmux" (
    { lib, pkgs, ... }:
    {
      wrappers.tmux = {
        sourceSensible = true;
        secureSocket = false;
        prefix = "C-Space";
        terminal = "screen-256color";
        mouse = true;
        escapeTime = 10;
        historyLimit = 2000;
        statusKeys = "vi";
        modeKeys = "vi";

        # Plugin settings. The plugins below read these settings when they load.
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

          # Since tmux 3.8, popups have a dark grey background by default. Use
          # the terminal background, as in panes.
          set -g popup-style default
          set -g popup-border-style fg=themelightgrey

          # Create new panes and new windows in the current working directory.
          bind -N "Split pane vertically" v split-window -hc "#{pane_current_path}"
          bind '|' split-window -hc "#{pane_current_path}"
          bind -N "Split pane horizontally" '"' split-window -vc "#{pane_current_path}"
          bind -N "New window" c new-window -c "#{pane_current_path}"

          unbind M-o
          bind -N "Rotate pane" "#" rotate-window

          # Pane navigation in copy mode. These bindings are equal to the C-hjkl
          # bindings outside copy mode.
          bind -T copy-mode-vi C-h select-pane -L
          bind -T copy-mode-vi C-j select-pane -D
          bind -T copy-mode-vi C-k select-pane -U
          bind -T copy-mode-vi C-l select-pane -R
          bind -T copy-mode-vi C-\\ select-pane -l
        '';
      };
    }
  );
}
