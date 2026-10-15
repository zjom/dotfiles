# devenv. devenv keeps its settings in ~/.config/devenv, so devenv is not a node
# (decision D14). On the hosts that install devenv, the prompt node adds the
# devenv hook to fish.
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
