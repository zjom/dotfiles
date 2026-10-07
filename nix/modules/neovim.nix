# Neovim, configured from ../../nvim. Language servers come from whichever dev
# shell it was launched in; the packages here are the few things Neovim itself
# shells out to: a C compiler for tree-sitter grammars, cargo for blink.cmp's
# fuzzy matcher, and the node/python providers.
{
  homeManager.base =
    { config, pkgs, ... }:
    {
      home.packages = with pkgs; [
        cargo
        gcc
        neovim
        nodejs
        python3
        tree-sitter
      ];

      xdg.configFile."nvim".source =
        config.lib.file.mkOutOfStoreSymlink "${config.my.dotfilesRoot}/nvim";

      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        MANPAGER = "nvim +Man!";
      };
    };
}
