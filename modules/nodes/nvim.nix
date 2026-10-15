# Leaf node: Neovim, configured from ../../nvim. The configuration directory is
# copied into the store; ~/.config/nvim is kept off the runtimepath and its
# init.lua is never run.
#
# Plugins are still installed by vim.pack at run time, into the data directory,
# and pinned by the nvim-pack-lock.json that vim.pack keeps in
# stdpath("config") (decision D13). Language servers come from whichever dev
# shell Neovim was started in; runtimePkgs are appended to PATH, so a dev
# shell's tools win.
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  nodes.nvim =
    { lib, pkgs, ... }:
    {
      imports = [
        (wlib.getInstallModule {
          name = "neovim";
          value = wlib.wrapperModules.neovim;
        })
      ];

      entry = lib.mkDefault "nvim";

      wrappers.neovim = {
        enable = true;
        settings.config_directory = ../../nvim;

        # What the plugin manager and the plugins themselves shell out to
        # (decision D15): git for vim.pack, a C compiler and the tree-sitter CLI
        # for grammars, cargo for blink.cmp's fuzzy matcher. The language
        # providers are switched off in options.lua.
        runtimePkgs = with pkgs; [
          cargo
          gcc
          git
          tree-sitter
        ];
      };
    };
}
