# The MacBook, on nix-darwin.
top@{ inputs, ... }:

let
  inherit (top.config.flake.modules) darwin;
  inherit (top.config) nodes;
in
{
  flake.darwinConfigurations.macbook = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      darwin.base
      nodes.env
      nodes.mac-desktop

      (
        { config, pkgs, ... }:
        {
          nixpkgs.hostPlatform = "aarch64-darwin";
          my.username = "zihanjin";
          my.hostName = "macbook";

          # Installed outside Nix; source them only where they exist.
          wrappers.fish.configFile.content = ''
            if status is-interactive
                test -f ~/.orbstack/shell/init2.fish; and source ~/.orbstack/shell/init2.fish 2>/dev/null
                test -f ~/Library/Google/google-cloud-sdk/path.fish.inc; and source ~/Library/Google/google-cloud-sdk/path.fish.inc
            end
          '';

          home-manager.sharedModules = [
            (
              { osConfig, ... }:
              {
                # The server of nodes.aerospace, started at login. The wrapper
                # carries its configuration, so Home Manager writes none.
                programs.aerospace = {
                  enable = true;
                  package = osConfig.wrappers.aerospace.wrapper;
                  launchd.enable = true;
                };
              }
            )
          ];

          environment.systemPackages = with pkgs; [
            duti
            pngpaste
          ];

          # macOS defaults, launchd agents, Homebrew and the rest of the nix-darwin
          # options belong here: they have no counterpart on the NixOS host.
          #   https://nix-darwin.github.io/nix-darwin/manual/

          # Required by the nix-darwin options that act on behalf of a single user.
          system.primaryUser = config.my.username;

          users.users.${config.my.username} = {
            name = config.my.username;
            home = "/Users/${config.my.username}";
          };

          # Homebrew is kept only for what Nix cannot install well: GUI apps and App
          # Store purchases. `cleanup = "zap"` uninstalls anything not listed here on
          # every rebuild -- including its application data -- so a stray
          # `brew install` never survives and no tool is ever installed twice.
          homebrew = {
            enable = true;

            onActivation = {
              autoUpdate = true;
              upgrade = true;
              cleanup = "zap";
            };

            brews = [
              "mas" # used by brew bundle to install masApps
            ];

            casks = [
              "alfred"
              "iina"
              "jordanbaird-ice"
              "orbstack"
              "shottr"
              "spotify"
            ];

            masApps = {
              "Dropover" = 1355679052;
            };
          };

          # Touch ID for sudo, working inside tmux too.
          security.pam.services.sudo_local = {
            reattach = true;
            touchIdAuth = true;
          };

          # The nix-darwin state version, an integer unrelated to the NixOS one.
          system.stateVersion = 6;
        }
      )
    ];
  };
}
