# Composite node: git authenticates to GitHub through gh. gh itself is not a
# node. gh writes its login to its own configuration directory, so gh stays with
# Home Manager (decision D14). git calls gh by name.
{ config, ... }:
{
  nodes.github = {
    imports = with config.nodes; [ git ];

    entry = "git";

    wrappers.git.settings.credential =
      let
        helper = {
          # Clear each helper that was set before this helper. Then use gh.
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
