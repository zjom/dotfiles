# The wrapper copies ./nvim into the store. vim.pack installs the plugins at
# run time, and nvim-pack-lock.json pins them (see default.nix). The language
# servers come from the dev shell, which comes first on PATH.
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
            settings.config_directory = ./nvim;

            # The tools that the plugin manager and the plugins call:
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
