# tmux.conf itself is an out-of-store symlink (see dotfiles.nix), so Home
# Manager cannot write into ~/.config/tmux. The plugins therefore land in the
# data directory instead, and tmux.conf sources them by path -- which is all
# tpm was doing, minus the git clones it kept outside Nix.
{ pkgs, ... }:

let
  plugin = name: pkg: {
    "tmux/plugins/${name}".source = "${pkg}/share/tmux-plugins/${name}";
  };
in
{
  xdg.dataFile =
    plugin "sensible" pkgs.tmuxPlugins.sensible
    // plugin "yank" pkgs.tmuxPlugins.yank
    // plugin "minimal-tmux-status" pkgs.tmuxPlugins.minimal-tmux-status;
}
