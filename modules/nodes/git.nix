# Leaf node: git.
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  nodes.git =
    { lib, ... }:
    {
      imports = [
        (wlib.getInstallModule {
          name = "git";
          value = wlib.wrapperModules.git;
        })
      ];

      entry = lib.mkDefault "git";

      # The upstream module sets GIT_CONFIG_GLOBAL to the generated file. Thus,
      # git ignores ~/.gitconfig and ~/.config/git/config.
      wrappers.git = {
        enable = true;
        settings = {
          user = {
            name = "Zihan Jin";
            email = "admin@zihanjin.com";
          };
          init.defaultBranch = "main";
        };
      };
    };
}
