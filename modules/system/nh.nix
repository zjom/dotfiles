# nh on each host, with the path of the checkout of this flake, and the
# `rebuild` alias that runs nh. Both values depend on the machine (the home
# directory of the user, the name of the configuration). Thus, both values are
# host-level overrides of the nh node and of the fish node.
{ config, ... }:

let
  inherit (config) nodes;

  rebuild =
    platform:
    { config, ... }:
    {
      imports = [
        nodes.nh
        nodes.fish
      ];

      wrappers.nh.flake = "${config.users.users.${config.my.username}.home}/dotfiles";

      # This setting names the configuration explicitly. Without this setting,
      # nh uses the hostname of the machine. Under WSL, the hostname is "nixos",
      # not "wsl".
      wrappers.fish.shellAliases.rebuild = "nh ${platform} switch -H ${config.my.hostName}";
    };
in
{
  flake.modules.nixos.base = rebuild "os";
  flake.modules.darwin.base = rebuild "darwin";
}
