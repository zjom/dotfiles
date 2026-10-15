# Composite node: git authenticating to GitHub through gh. gh itself is not a
# node: it writes its login to its own configuration directory, so it stays
# with Home Manager (decision D14), and git reaches it by name.
{ config, ... }:
{
  nodes.github = {
    imports = with config.nodes; [ git ];

    entry = "git";

    wrappers.git.settings.credential =
      let
        helper = {
          # Clear any helper set before this one, then ask gh.
          helper = [
            ""
            "!gh auth git-credential"
          ];
        };
      in
      {
        "https://github.com" = helper;
        "https://gist.github.com" = helper;
      };
  };
}
