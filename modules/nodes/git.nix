# Leaf node: git.
{ leaf, ... }:
{
  # The upstream module sets GIT_CONFIG_GLOBAL to the generated file. Thus,
  # git ignores ~/.gitconfig and ~/.config/git/config.
  nodes.git = leaf "git" {
    wrappers.git.settings = {
      user = {
        name = "Zihan Jin";
        email = "admin@zihanjin.com";
      };
      init.defaultBranch = "main";
    };
  };
}
