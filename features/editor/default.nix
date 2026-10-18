# The editor: Neovim as the editor of the other programs.
{ config, ... }:
{
  nodes.editor =
    { pkgs, ... }:
    let
      # Exits with 0 if a process under the pane runs Neovim or fzf. A check of
      # the pane tty only is not sufficient: devenv shell starts its shell on a
      # pty of its own.
      is-vim = pkgs.writeShellScript "is-vim" ''
        ${pkgs.procps}/bin/ps -e -o pid= -o ppid= -o state= -o comm= | ${pkgs.gawk}/bin/awk -v root="$1" '
          { ppid[$1] = $2; state[$1] = $3; comm[$1] = tolower($4) }
          END {
            for (pid in ppid) {
              if (state[pid] ~ /^[TXZ]/ || comm[pid] !~ /^g?(view|l?n?vim?x?|fzf)(diff)?$/) continue
              for (p = pid; p != "" && p != root && p != 0; p = ppid[p]) {}
              if (p == root) exit 0
            }
            exit 1
          }'
      '';
    in
    {
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
        is_vim="${is-vim} #{pane_pid}"

        bind -n C-h if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
        bind -n C-j if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
        bind -n C-k if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
        bind -n C-l if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
        bind -n 'C-\' if-shell "$is_vim" 'send-keys C-\\' 'select-pane -l'
      '';
    };

  # vim.pack keeps nvim-pack-lock.json in stdpath("config"), ~/.config/nvim.
  # This link puts that directory in the checkout, where `vim.pack.update()`
  # writes the lockfile. The wrapped Neovim loads no other files from it.
  flake.modules.homeManager.base =
    { config, ... }:
    {
      xdg.configFile."nvim".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/features/editor/nvim";
    };
}
