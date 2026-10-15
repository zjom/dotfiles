# Leaf node: spotify-player, the terminal client for Spotify. A Spotify Connect
# daemon plays the audio. Home Manager runs this daemon (spotifyd) in
# modules/system/spotifyd.nix. The device depends on the machine, so each host
# sets `wrappers.spotify-player.settings.default_device`. The login is state in
# the cache directory, outside the configuration.
{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;

  # nix-wrapper-modules has no module for spotify-player. This module is a local
  # module. The app.toml settings are an option, so a host can extend the
  # settings.
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
        # This directory replaces ~/.config/spotify-player.
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
          # The Connect daemon plays the audio. spotify-player connects to the
          # daemon by name.
          enable_streaming = "Never";
          playback_window_position = "Top";
          # By default, spotify-player reads playlists through the shared ncspot
          # client. The quota of that client is almost always used up. Thus,
          # send the requests through our own client first. If the response is a
          # 4xx error, spotify-player still uses ncspot. An example is a
          # playlist that Spotify owns.
          ncspot_only_get_endpoints = [ ];
          enable_notify = false;
        };
      };
    };
}
