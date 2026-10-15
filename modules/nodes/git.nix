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

      # The upstream module points GIT_CONFIG_GLOBAL at the generated file, so
      # ~/.gitconfig and ~/.config/git/config are ignored.
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
