# Leaf node: spotify-player, the terminal Spotify client. Playback is left to
# a Spotify Connect daemon (spotifyd, run by Home Manager in modules/sptfy.nix);
# which device that is depends on the machine, so each host sets
# `wrappers.spotify-player.settings.default_device`. The login is state in the
# cache folder, outside the configuration.
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;

  # nix-wrapper-modules has no module for spotify-player: a local one, with the
  # app.toml settings as an option so a host can extend them.
  module =
    {
      config,
      lib,
      pkgs,
      wlib,
      ...
    }:
    let
      toml = pkgs.formats.toml { };
    in
    {
      imports = [ wlib.modules.default ];

      options.settings = lib.mkOption {
        inherit (toml) type;
        default = { };
        description = "spotify-player's app.toml.";
      };

      config = {
        package = lib.mkDefault pkgs.spotify-player;
        # In place of ~/.config/spotify-player.
        flags."--config-folder" = "${pkgs.linkFarm "spotify-player-config" {
          "app.toml" = toml.generate "app.toml" config.settings;
        }}";
      };
    };
in
{
  nodes.spotify-player =
    { lib, ... }:
    {
      imports = [
        (wlib.getInstallModule {
          name = "spotify-player";
          value = module;
        })
      ];

      entry = lib.mkDefault "spotify_player";

      wrappers.spotify-player = {
        enable = true;
        settings = {
          client_id = "6698cb5b027840b9a170b92747ed8903";
          # Leave playback to the Connect daemon and connect to it by name.
          enable_streaming = "Never";
          playback_window_position = "Top";
          # Playlist reads default to the shared ncspot client, whose quota is
          # constantly exhausted. Send them through our own client first; ncspot
          # is still the fallback on any 4xx (e.g. Spotify-owned playlists).
          ncspot_only_get_endpoints = [ ];
          enable_notify = false;
        };
      };
    };
}
