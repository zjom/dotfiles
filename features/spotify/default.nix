# spotifyd plays the audio as a Spotify Connect device. spotify-player controls
# spotifyd.
#
# On each machine, authenticate spotifyd one time, with OAuth in the browser:
#
#   spotifyd authenticate
#
# spotify-player signs in when it starts for the first time.
{ config, ... }:

let
  inherit (config) nodes;

  # spotifyd uses the name of the configuration as its device name.
  # spotify-player connects to that device.
  player =
    { config, ... }:
    {
      imports = [ nodes.spotify-player ];
      wrappers.spotify-player.settings.default_device = config.my.hostName;
    };
in
{
  flake.modules.nixos.base = player;
  flake.modules.darwin.base = player;

  flake.modules.homeManager.base =
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

      deviceName = osConfig.my.hostName;
      cachePath = "${config.xdg.cacheHome}/spotifyd";

      # The service starts with an explicit --config-path. The file is also
      # written to the default location, so that `spotifyd authenticate` finds
      # it.
      configFile = tomlFormat.generate "spotifyd.conf" {
        global = {
          device_name = deviceName;
          device_type = "computer";
          # On Linux, the server is pipewire-pulse on the desktop and the
          # PulseAudio server of WSLg under WSL.
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

      # spotify-player without its TUI. Thus, `spotify_player playback ...` and
      # the lm10-spotify picker use the client that runs, and each command does
      # not start its own client. -d forks and detaches, so the service uses
      # Type=forking.
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
          ExecStart = "${lib.getExe' osConfig.wrappers.spotify-player.wrapper "spotify_player"} --daemon";
          Restart = "on-failure";
          RestartSec = 12;
        };
      };
    };
}
