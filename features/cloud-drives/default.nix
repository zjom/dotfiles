# Google Drive and iCloud Drive as folders in /mnt, mounted with rclone. Each
# host gets the rclone CLI. Only a host with the desktop mounts the drives.
#
# The mounts are not in ~, so that `ls ~` does not wait for the cloud providers.
# A user service cannot make folders in /mnt, so the system makes them with
# tmpfiles and gives them to the user.
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
  # The names of the rclone remotes. Each one mounts on /mnt/<remote>.
  remotes = [
    "gdrive"
    "icloud"
  ];
in
{
  flake.modules.nixos.desktop =
    { config, ... }:
    let
      user = config.users.users.${config.my.username};
    in
    {
      systemd.tmpfiles.rules = map (remote: "d /mnt/${remote} 0755 ${user.name} ${user.group} -") remotes;
    };

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
        remote:
        let
          path = "/mnt/${remote}";
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
      systemd.user.services = lib.listToAttrs (map mount remotes);
    };
}
