# vim.pack keeps nvim-pack-lock.json in stdpath("config"), ~/.config/nvim.
# Linking that directory to the checkout keeps the lockfile in the repository,
# where `vim.pack.update()` rewrites it, so the plugins stay pinned by a
# committed file (decision D13). The wrapped Neovim of nodes.nvim never loads
# anything else from it: its init.lua is not run and it is off the
# runtimepath.
{
  flake.modules.homeManager.base =
    { config, ... }:
    {
      xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.my.dotfilesRoot}/nvim";
    };
}
