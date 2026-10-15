# Composite node: lazygit in a tmux popup and as `lg` in fish.
{ config, ... }:
{
  nodes.git-ui = {
    imports = with config.nodes; [
      fish
      tmux
      lazygit
      git
    ];

    entry = "lazygit";

    wrappers.fish.shellAliases.lg = "lazygit";

    wrappers.tmux.configAfter = ''
      bind -N "Popup LazyGit" g popup -E -d "#{pane_current_path}" -w 90% -h 90% "lazygit"
      bind -N "Popup LazyGit" c-g popup -E -d "#{pane_current_path}" -w 90% -h 90% "lazygit"
    '';
  };
}
