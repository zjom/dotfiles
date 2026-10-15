# gh, logged in once per machine with `gh auth login`. gh writes that login
# into its own configuration directory, so it is not a node (decision D14);
# git reaches it by name through the github node's credential helper.
{
  flake.modules.homeManager.base = {
    programs.gh = {
      enable = true;
      settings = {
        version = "1";
        git_protocol = "ssh";
      };
    };
  };
}
