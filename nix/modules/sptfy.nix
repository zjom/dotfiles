# Spotify on every host: spotifyd plays the audio as a Spotify Connect device
# in the background, and spotify-player is the terminal client that drives it.
#
# spotifyd authenticates once per machine, with OAuth in the browser:
#
#   spotifyd authenticate
#
# It reads the same config file as the daemon, so the credentials land in the
# cache_path below, where the service finds them. spotify-player signs in
# separately on its first start (or with `spotify_player authenticate`).
{
  homeManager.base =
    {
      config,
      osConfig,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
      tomlFormat = pkgs.formats.toml { };

      # What the device is called in every Spotify client's device list.
      deviceName = osConfig.my.hostName;
      cachePath = "${config.xdg.cacheHome}/spotifyd";

      # Started with an explicit --config-path, but written to the default
      # location as well so that `spotifyd authenticate` picks it up.
      configFile = tomlFormat.generate "spotifyd.conf" {
        global = {
          device_name = deviceName;
          device_type = "computer";
          # pipewire-pulse on the desktop, WSLg's PulseAudio server under WSL.
          backend = if isDarwin then "portaudio" else "pulseaudio";
          bitrate = 320;
          cache_path = cachePath;
          max_cache_size = 2 * 1024 * 1024 * 1024;
          initial_volume = 60;
          volume_normalisation = true;
          autoplay = false;
          use_mpris = isLinux;
          dbus_type = "session";
        };
      };

      command = [
        "${pkgs.spotifyd}/bin/spotifyd"
        "--no-daemon"
        "--config-path"
        "${configFile}"
      ];
    in
    {
      home.packages = [ pkgs.spotifyd ];
      xdg.configFile."spotifyd/spotifyd.conf".source = configFile;

      systemd.user.services.spotifyd = lib.mkIf isLinux {
        Unit = {
          Description = "Spotify Connect daemon";
          Documentation = "https://github.com/Spotifyd/spotifyd";
        };
        Install.WantedBy = [ "default.target" ];
        Service = {
          ExecStart = lib.escapeShellArgs command;
          Restart = "always";
          RestartSec = 12;
        };
      };

      launchd.agents.spotifyd = lib.mkIf isDarwin {
        enable = true;
        config = {
          ProgramArguments = command;
          RunAtLoad = true;
          KeepAlive = true;
          ProcessType = "Interactive";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/spotifyd.log";
        };
      };

      # spotify-player without its TUI, so `spotify_player playback ...` and
      # the lm10-spotify picker talk to a running client instead of each
      # starting their own. -d forks and detaches, hence Type=forking.
      systemd.user.services.spotify-player = lib.mkIf isLinux {
        Unit = {
          Description = "spotify-player daemon";
          Documentation = "https://github.com/aome510/spotify-player";
          After = [ "spotifyd.service" ];
          Wants = [ "spotifyd.service" ];
        };
        Install.WantedBy = [ "default.target" ];
        Service = {
          Type = "forking";
          ExecStart = "${lib.getExe' config.programs.spotify-player.package "spotify_player"} --daemon";
          Restart = "on-failure";
          RestartSec = 12;
        };
      };

      programs.spotify-player = {
        enable = true;
        settings = {
          client_id = "6698cb5b027840b9a170b92747ed8903";
          # Leave playback to spotifyd and connect to it by name.
          enable_streaming = "Never";
          default_device = deviceName;
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
