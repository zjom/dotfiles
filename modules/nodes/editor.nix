# Composite node: Neovim as the editor for all other programs. This node
# contains only the glue between nvim and fish, tmux and git.
{ config, ... }:
{
  nodes.editor = {
    imports = with config.nodes; [
      nvim
      fish
      tmux
      git
      fzf
    ];

    entry = "nvim";

    wrappers.fish = {
      shellAliases = {
        nv = "nvim";
        nvi = "nvim";
        nvm = "nvim";
        vim = "nvim";
      };

      env = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        MANPAGER = "nvim +Man!";
      };
    };

    wrappers.git.settings.core.editor = "nvim";

    # Pane navigation: C-hjkl moves between tmux panes. If the pane runs Neovim
    # or fzf, tmux sends the keys to that program.
    wrappers.tmux.configAfter = ''
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"

      bind -n C-h if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
      bind -n C-j if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
      bind -n C-k if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
      bind -n C-l if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
      bind -n 'C-\' if-shell "$is_vim" 'send-keys C-\\' 'select-pane -l'
    '';
  };
}
