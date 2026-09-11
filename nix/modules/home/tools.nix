# Command line tools that are configured here rather than in the dotfiles
# checkout, because Home Manager also has to wire their shell integration.
{ ... }:

let
  # Directories that are never worth searching, walking or listing.
  noise = [
    ".git"
    ".jj"
    "node_modules"
    ".venv"
    "venv"
  ];
in
{
  programs = {
    eza = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    fd = {
      enable = true;
      ignores = noise;
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      tmux.enableShellIntegration = true;
    };

    lazygit.enable = true;

    ripgrep = {
      enable = true;
      arguments = [
        "--hidden"
        "--smart-case"
        "--glob=!.DS_Store"
      ]
      ++ map (dir: "--glob=!${dir}/*") noise;
    };

    sesh = {
      enable = true;
      enableTmuxIntegration = true;
    };

    starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
  };
}
