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
