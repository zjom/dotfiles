{ leaf, ... }:
{
  nodes.git = leaf "git" {
    wrappers.git.settings = {
      user = {
        name = "Zihan Jin";
        email = "admin@zihanjin.com";
      };
      init.defaultBranch = "main";

      # git authenticates to GitHub through gh. gh is not a node: gh writes its
      # login into its own configuration directory.
      credential =
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
  };
}
