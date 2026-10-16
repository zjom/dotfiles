# Nix itself, and the `rebuild` alias that runs nh on the checkout of this flake.
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
  flake.modules.nixos.base = {
    imports = [ (rebuild "os") ];

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Lets unpatched, dynamically linked binaries run. Language toolchains that
    # are installed outside Nix often need this setting.
    programs.nix-ld.enable = true;
  };

  flake.modules.darwin.base = {
    imports = [ (rebuild "darwin") ];

    # The Lix installer installs and updates Nix itself, outside this flake. The
    # Lix installer owns /etc/nix/nix.conf and the nix-daemon launchd job. If this
    # option is off, nix-darwin does not change these two items.
    #
    # To give the daemon to nix-darwin, set `nix.enable = true` and
    # `nix.package = pkgs.lix`. Before you do this, move /etc/nix/nix.conf to a
    # different path, so that activation can replace the file. After that change,
    # the `nix.settings` and `nix.gc` options above also apply on macOS.
    nix.enable = false;
  };
}
