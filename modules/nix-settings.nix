# Nix itself: its settings and garbage collection.
{
  nixos.base = {
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

    # Lets unpatched dynamically linked binaries run, which language
    # toolchains installed outside Nix tend to need.
    programs.nix-ld.enable = true;
  };

  # Nix itself is installed and updated outside this flake, by the Lix
  # installer, which owns /etc/nix/nix.conf and the nix-daemon launchd job.
  # Leaving this off keeps nix-darwin away from both.
  #
  # To hand the daemon over to nix-darwin instead, set `nix.enable = true`
  # with `nix.package = pkgs.lix`, and first move /etc/nix/nix.conf aside so
  # activation is allowed to replace it. Only then do the `nix.settings` and
  # `nix.gc` options above have a counterpart here.
  darwin.base.nix.enable = false;
}
