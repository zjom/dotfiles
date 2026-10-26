{ leaf, ... }:
{
  nodes.git = leaf "git" (
    { lib, pkgs, ... }:
    {
      wrappers.git.settings = {
        user = {
          name = "Zihan Jin";
          email = "admin@zihanjin.com";
        };
        init.defaultBranch = "main";

        # git authenticates to GitHub through gh. gh is not a node: gh writes its
        # login into its own configuration directory. The store path makes the
        # helper work without a gh on PATH.
        credential =
          let
            helper = {
              # Clear each helper that was set before this helper. Then use gh.
              helper = [
                ""
                "!${lib.getExe pkgs.gh} auth git-credential"
              ];
            };
          in
          {
            "https://github.com" = helper;
            "https://gist.github.com" = helper;
          };
      };
    }
  );
}
