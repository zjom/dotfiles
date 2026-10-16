# Git: lazygit in a tmux popup and as `lg` in fish, and gh.
{ config, ... }:
{
  nodes.git-ui =
    { pkgs, ... }:
    {
      imports = with config.nodes; [
        fish
        tmux
        git
      ];

      packages = [ pkgs.lazygit ];

      entry = "lazygit";

      wrappers.fish.shellAliases.lg = "lazygit";

      wrappers.tmux.configAfter = ''
        bind -N "Popup LazyGit" g popup -E -d "#{pane_current_path}" -w 90% -h 90% "lazygit"
        bind -N "Popup LazyGit" c-g popup -E -d "#{pane_current_path}" -w 90% -h 90% "lazygit"
      '';
    };

  # On each machine, log in one time with `gh auth login`.
  flake.modules.homeManager.base.programs.gh = {
    enable = true;
    settings = {
      version = "1";
      git_protocol = "ssh";
    };
  };
}
