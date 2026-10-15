# gh. On each machine, log in one time with `gh auth login`. gh writes the login
# into its own configuration directory, so gh is not a node (decision D14). git
# calls gh by name through the credential helper of the github node.
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
