# devenv, which keeps its settings in ~/.config/devenv and is not a node
# (decision D14). The prompt node hooks it into fish where it is installed.
{
  flake.modules.homeManager.base = {
    programs.devenv = {
      enable = true;
      enableFishIntegration = false;
      settings = {
        shell = {
          prompt_prefix = false;
        };
        tui = {
          statusline = {
            enabled = false;
          };
        };
      };
    };
  };
}
