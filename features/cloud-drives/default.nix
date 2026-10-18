# Google Drive and iCloud Drive as folders in ~, mounted with rclone. Each host
# gets the rclone CLI. Only a host with the desktop mounts the drives.
#
# rclone keeps the tokens in ~/.config/rclone/rclone.conf, outside this
# repository. On each machine, create the remotes one time with `rclone config`:
#
#   gdrive   type `drive`, OAuth in the browser
#   icloud   type `iclouddrive`, Apple ID, password and a 2FA code
#
# iCloud needs "Access iCloud Data on the Web" on and Advanced Data Protection
# off. The iCloud session expires after about 30 days. Then run
# `rclone config reconnect icloud:`.
#
# Until a remote exists, its mount service fails and tries again every minute.
# After you create the remote, run `systemctl --user restart rclone-<remote>`.
{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.rclone ];
    };

  flake.modules.homeManager.desktop =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      rclone = lib.getExe pkgs.rclone;

      # The name of the rclone remote, and the folder in ~ that it mounts on.
      drives = {
        gdrive = "GoogleDrive";
        icloud = "iCloud";
      };

      mount =
        remote: dir:
        let
          path = "${config.home.homeDirectory}/${dir}";
        in
        lib.nameValuePair "rclone-${remote}" {
          Unit = {
            Description = "rclone mount of ${remote}: on ~/${dir}";
            Documentation = "https://rclone.org/commands/rclone_mount/";
          };
          Install.WantedBy = [ "default.target" ];
          Service = {
            # rclone tells systemd when the mount is ready.
            Type = "notify";
            # rclone runs fusermount3, and NixOS has the setuid fusermount3 only
            # in /run/wrappers/bin.
            Environment = [ "PATH=/run/wrappers/bin" ];
            ExecStartPre = "${lib.getExe' pkgs.coreutils "mkdir"} -p ${path}";
            ExecStart = lib.escapeShellArgs [
              rclone
              "mount"
              "${remote}:"
              path
              # Full caching, so programs can open files for writing and seek in
              # them. The cache is in ~/.cache/rclone.
              "--vfs-cache-mode"
              "full"
              "--vfs-cache-max-size"
              "10G"
              "--dir-cache-time"
              "5m"
            ];
            ExecStop = "/run/wrappers/bin/fusermount3 -uz ${path}";
            Restart = "on-failure";
            RestartSec = 60;
          };
        };
    in
    {
      systemd.user.services = lib.mapAttrs' mount drives;
    };
}
