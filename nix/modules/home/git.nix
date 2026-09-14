{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Zihan Jin";
        email = "admin@zihanjin.com";
      };
      core = {
        editor = "nvim";
      };
      init = {
        defaultBranch = "main";
      };
      merge = {
        conflictStyle = "zdiff3";
      };
    };
  };

  # `delta` as git's pager; `navigate` puts n/N on diff sections.
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      dark = true;
    };
  };

  programs.gh = {
    enable = true;

    # Writes the credential.https://github.com helper for us. The hand-written
    # .gitconfig pointed at /opt/homebrew/bin/gh, a path that no longer exists.
    gitCredentialHelper = {
      enable = true;
      hosts = [
        "https://github.com"
        "https://gist.github.com"
      ];
    };

    settings = {
      version = "1";
      git_protocol = "ssh";
    };
  };
}
