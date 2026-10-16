# Leaf node: Neovim, configured from ../../nvim. The wrapper copies the
# configuration directory into the store. ~/.config/nvim is not on the
# runtimepath, and Neovim never runs the init.lua file in that directory.
#
# vim.pack still installs the plugins at run time, into the data directory. The
# nvim-pack-lock.json file pins the plugins. vim.pack keeps this file in
# stdpath("config") (decision D13). The language servers come from the dev shell
# that started Neovim. The wrapper appends runtimePkgs to PATH, so the tools of
# a dev shell have priority.
{ leaf, ... }:
{
  nodes.nvim =
    leaf
      {
        name = "neovim";
        entry = "nvim";
      }
      (
        { pkgs, ... }:
        {
          wrappers.neovim = {
            settings.config_directory = ../../nvim;

            # The tools that the plugin manager and the plugins call (decision D15):
            # git for vim.pack, a C compiler and the tree-sitter CLI for the
            # grammars, and cargo for the fuzzy matcher of blink.cmp. options.lua
            # disables the language providers.
            runtimePkgs = with pkgs; [
              cargo
              gcc
              git
              tree-sitter
            ];
          };
        }
      );
}
