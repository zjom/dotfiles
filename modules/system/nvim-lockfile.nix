# vim.pack keeps nvim-pack-lock.json in stdpath("config"), ~/.config/nvim. This
# module links that directory to the checkout. Thus, the lockfile is in the
# repository, where `vim.pack.update()` writes it. A committed file then pins
# the plugins (decision D13). The wrapped Neovim of nodes.nvim loads no other
# files from that directory. Neovim does not run its init.lua file, and the
# directory is not on the runtimepath.
{
  flake.modules.homeManager.base =
    { config, ... }:
    {
      xdg.configFile."nvim".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim";
    };
}
