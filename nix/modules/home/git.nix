{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Zihan Jin";
        email = "admin@zihanjin.com";
      };
      init = {
        defaultBranch = "main";
      };
    };
  };
}
