# nh on every host, pointed at this flake's checkout, and the `rebuild` alias
# that runs it. Both depend on the machine (its user's home, its configuration
# name), so they are host-level overrides of the nh and fish nodes.
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

      # The configuration is named outright: nh would otherwise go by the
      # machine's hostname, which under WSL is "nixos" rather than "wsl".
      wrappers.fish.shellAliases.rebuild = "nh ${platform} switch -H ${config.my.hostName}";
    };
in
{
  flake.modules.nixos.base = rebuild "os";
  flake.modules.darwin.base = rebuild "darwin";
}
