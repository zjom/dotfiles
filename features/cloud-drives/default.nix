# Google Drive and iCloud Drive as folders in /run/user/<uid>, mounted with
# rclone. Each host gets the rclone CLI. Only a host with the desktop mounts the
# drives.
#
# The mounts are not in ~, so that programs that walk ~ do not go into the cloud
# providers. /run/user/<uid> is where the user's FUSE mounts usually go: the
# user owns it, and systemd removes it at logout. A symlink in ~ points to each
# mount. Programs such as fd and rg do not follow symlinks unless told to.
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
let
  # The name of the rclone remote, and the symlink in ~ to its mount. Each remote
  # mounts on /run/user/<uid>/<remote>.
  drives = {
    gdrive = "GoogleDrive";
    icloud = "iCloud";
  };
in
{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.rclone ];
    };

  flake.modules.homeManager.desktop =
    { lib, pkgs, ... }:
    let
      rclone = lib.getExe pkgs.rclone;

      mount =
        remote: link:
        let
          # systemd replaces %t with /run/user/<uid>, and %h with ~.
          path = "%t/${remote}";
        in
        lib.nameValuePair "rclone-${remote}" {
          Unit = {
            Description = "rclone mount of ${remote}: on ${path}";
            Documentation = "https://rclone.org/commands/rclone_mount/";
          };
          Install.WantedBy = [ "default.target" ];
          Service = {
            # rclone tells systemd when the mount is ready.
            Type = "notify";
            # rclone runs fusermount3, and NixOS has the setuid fusermount3 only
            # in /run/wrappers/bin.
            Environment = [ "PATH=/run/wrappers/bin" ];
            ExecStartPre = [
              "${lib.getExe' pkgs.coreutils "mkdir"} -p ${path}"
              # The uid is not known when Nix builds the config, so the service
              # makes the symlink. -T makes ln fail, not write into ~/${link},
              # if ~/${link} is a folder.
              "${lib.getExe' pkgs.coreutils "ln"} -sfnT ${path} %h/${link}"
            ];
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
