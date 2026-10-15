# Nix itself: the settings and the garbage collection.
{
  flake.modules.nixos.base = {
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

  # The Lix installer installs and updates Nix itself, outside this flake. The
  # Lix installer owns /etc/nix/nix.conf and the nix-daemon launchd job. If this
  # option is off, nix-darwin does not change these two items.
  #
  # To give the daemon to nix-darwin, set `nix.enable = true` and
  # `nix.package = pkgs.lix`. Before you do this, move /etc/nix/nix.conf to a
  # different path, so that activation can replace the file. After that change,
  # the `nix.settings` and `nix.gc` options above also apply on macOS.
  flake.modules.darwin.base.nix.enable = false;
}
