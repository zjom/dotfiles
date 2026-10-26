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
      darwin.mac-desktop

      (
        { config, pkgs, ... }:
        {
          nixpkgs.hostPlatform = "aarch64-darwin";
          my.username = "zihanjin";
          my.hostName = "macbook";

          # These files are installed outside Nix. Source each file only if it
          # exists.
          wrappers.fish.configFile.content = ''
            if status is-interactive
                test -f ~/.orbstack/shell/init2.fish; and source ~/.orbstack/shell/init2.fish 2>/dev/null
                test -f ~/Library/Google/google-cloud-sdk/path.fish.inc; and source ~/Library/Google/google-cloud-sdk/path.fish.inc
            end
          '';

          environment.systemPackages = with pkgs; [
            duti
            pngpaste
          ];

          # The nix-darwin options that act for a single user require this
          # value.
          system.primaryUser = config.my.username;

          users.users.${config.my.username} = {
            name = config.my.username;
            home = "/Users/${config.my.username}";
          };

          # Homebrew installs only the software that Nix cannot install well:
          # GUI apps and App Store purchases. On each rebuild, `cleanup = "zap"`
          # uninstalls all software that is not in this list, including the
          # application data. Thus, a manual `brew install` is always removed,
          # and no tool is installed two times.
          homebrew = {
            enable = true;

            onActivation = {
              autoUpdate = true;
              upgrade = true;
              cleanup = "zap";
            };

            brews = [
              "mas" # brew bundle uses mas to install masApps
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

          # Touch ID for sudo, also inside tmux.
          security.pam.services.sudo_local = {
            reattach = true;
            touchIdAuth = true;
          };

          # The nix-darwin state version. This value is an integer and is not
          # related to the NixOS state version.
          system.stateVersion = 6;

          # The Home Manager release of the first activation on this host. Do
          # not change this value after that.
          home-manager.users.${config.my.username}.home.stateVersion = "26.05";
        }
      )
    ];
  };
}
